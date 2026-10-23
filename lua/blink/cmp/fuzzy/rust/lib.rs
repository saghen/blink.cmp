use crate::error::Error;
use crate::frecency::FrecencyDB;
use crate::fuzzy::FuzzyOptions;
use crate::lsp_item::LspItem;
use crate::sort::Sort;
use lsp_item::CompletionItemKind;
use mlua::prelude::*;
use regex::Regex;
use std::cmp::Ordering;
use std::collections::{HashMap, HashSet};
use std::sync::{LazyLock, RwLock};

mod error;
mod frecency;
mod fuzzy;
mod keyword;
mod lsp_item;
mod sort;

static REGEX: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"[\p{L}_][\p{L}0-9_\\-]{2,}").unwrap());
static FRECENCY: LazyLock<RwLock<Option<FrecencyDB>>> = LazyLock::new(|| RwLock::new(None));
static HAYSTACKS_BY_PROVIDER: LazyLock<RwLock<HashMap<String, Vec<LspItem>>>> =
    LazyLock::new(|| RwLock::new(HashMap::new()));

pub fn init_db(_: &Lua, db_path: String) -> LuaResult<bool> {
    let mut frecency = FRECENCY.write().map_err(|_| Error::AcquireFrecencyLock)?;
    if frecency.is_some() {
        return Ok(false);
    }
    *frecency = Some(FrecencyDB::new(&std::path::PathBuf::from(db_path))?);
    Ok(true)
}

pub fn destroy_db(_: &Lua, _: ()) -> LuaResult<bool> {
    let frecency = FRECENCY.write().map_err(|_| Error::AcquireFrecencyLock)?;
    drop(frecency);

    let mut frecency = FRECENCY.write().map_err(|_| Error::AcquireFrecencyLock)?;
    *frecency = None;

    Ok(true)
}

pub fn access(_: &Lua, item: LspItem) -> LuaResult<bool> {
    let mut frecency = FRECENCY.write().map_err(|_| Error::AcquireFrecencyLock)?;
    let frecency = frecency.as_mut().ok_or(Error::UseFrecencyBeforeInit)?;
    frecency.access(&(&item).into())?;
    Ok(true)
}

pub fn set_provider_items(
    _: &Lua,
    (provider_id, items): (String, Vec<LspItem>),
) -> LuaResult<bool> {
    HAYSTACKS_BY_PROVIDER
        .write()
        .map_err(|_| Error::AcquireItemLock)?
        .insert(provider_id, items);
    Ok(true)
}

pub fn fuzzy(
    _lua: &Lua,
    (line, cursor_col, provider_ids, opts): (mlua::String, usize, Vec<String>, FuzzyOptions),
) -> LuaResult<(Vec<u16>, Vec<u32>, Vec<i32>, Vec<bool>)> {
    // Gather static data
    let frecency = FRECENCY.read().map_err(|_| Error::AcquireFrecencyLock)?;
    let haystacks_by_provider = HAYSTACKS_BY_PROVIDER
        .read()
        .map_err(|_| Error::AcquireItemLock)?;

    // Perform fuzzy matching per provider and combine
    let mut matches = provider_ids
        .iter()
        .enumerate()
        .map(|(provider_idx, provider_id)| {
            let haystack = haystacks_by_provider.get(provider_id).ok_or_else(|| {
                Error::FuzzyBeforeSetItems {
                    provider_id: provider_id.to_string(),
                }
            })?;

            Ok(fuzzy::fuzzy(
                (provider_idx).try_into().unwrap(),
                &line.to_string_lossy(),
                cursor_col,
                haystack,
                frecency.as_ref(),
                opts.clone(),
            ))
        })
        .try_fold(Vec::new(), |mut acc, result: LuaResult<_>| {
            result.map(|mut vec| {
                acc.append(&mut vec);
                acc
            })
        })?;

    // Sort by provider idx then index in haystack
    matches.sort_by_key(|m| (m.provider_idx, m.mtch.index));

    // Sort by user-defined sorts
    if let Some(sorts) = opts.sorts {
        matches.sort_by(|a, b| {
            sorts.iter().fold(Ordering::Equal, |acc, sort| {
                if acc != Ordering::Equal {
                    return acc;
                }

                match sort {
                    // Reverse ordering
                    Sort::Exact => b.mtch.exact.cmp(&a.mtch.exact),
                    Sort::Score => b.score.cmp(&a.score),

                    // Regular ordering
                    Sort::Kind => a.item.kind.cmp(&b.item.kind),
                    Sort::SortText => match (&a.item.sort_text, &b.item.sort_text) {
                        (Some(a), Some(b)) => a.cmp(b),
                        // Consider results with Some value to be greater than those with None
                        (Some(_), None) => Ordering::Greater,
                        (None, Some(_)) => Ordering::Less,
                        // Neither has sort text
                        (None, None) => Ordering::Equal,
                    },
                    Sort::Label => Sort::label(a.item, b.item),
                }
            })
        })
    }

    Ok((
        matches.iter().map(|m| m.provider_idx).collect(),
        matches.iter().map(|m| m.mtch.index).collect(),
        matches.iter().map(|m| m.score).collect(),
        matches.iter().map(|m| m.mtch.exact).collect(),
    ))
}

pub fn fuzzy_matched_indices(
    _lua: &Lua,
    (line, cursor_col, haystack, match_suffix): (mlua::String, usize, Vec<mlua::String>, bool),
) -> LuaResult<Vec<Vec<u32>>> {
    Ok(fuzzy::fuzzy_matched_indices(
        &line.to_string_lossy(),
        cursor_col,
        &haystack
            .iter()
            .map(|s| s.to_string_lossy())
            .collect::<Vec<_>>(),
        match_suffix,
    ))
}

pub fn get_keyword_range(
    _lua: &Lua,
    (line, col, match_suffix): (mlua::String, usize, bool),
) -> LuaResult<(usize, usize)> {
    Ok(keyword::get_keyword_range(
        &line.to_string_lossy(),
        col,
        match_suffix,
    ))
}

pub fn guess_edit_range(
    _lua: &Lua,
    (item, line, cursor_col, match_suffix): (LspItem, mlua::String, usize, bool),
) -> LuaResult<(usize, usize)> {
    let line_str = line.to_string_lossy();

    let keyword_range = keyword::get_keyword_range(&line_str, cursor_col, match_suffix);
    let label_edit_range = keyword::guess_keyword_range(keyword_range, &item.label, &line_str);
    let filter_text_edit_range = item
        .filter_text
        .as_ref()
        .map(|filter_text| keyword::guess_keyword_range(keyword_range, filter_text, &line_str))
        .unwrap_or(label_edit_range);
    let insert_text_edit_range = item
        .insert_text
        .as_ref()
        .map(|insert_text| keyword::guess_keyword_range(keyword_range, insert_text, &line_str))
        .unwrap_or(filter_text_edit_range);

    // Prefer the insert text, then filter text, then label ranges for non-snippets
    if item.kind != CompletionItemKind::Snippet as u32 {
        return Ok(insert_text_edit_range);
    }

    // HACK: In the lazydev.nvim case, the label is the whole module like `blink.cmp.fuzzy`
    // but the `insertText` is just `fuzzy` when you've already typed `blink.cmp.`.
    // But in the snippets case, the label could be completed unrelated to the insertText so we
    // should use the label range.
    //
    // TODO: What about using the filterText range and ignoring label?

    // Take the max range prioritizing the start index first and the end index second
    // When comparing tuples (start, end), Rust compares the first element first,
    // and only if those are equal, it compares the second element
    Ok([
        label_edit_range,
        filter_text_edit_range,
        insert_text_edit_range,
    ]
    .iter()
    // Transform to (start, -end) to find minimum start and maximum end
    .min_by_key(|&(start, end)| (start, std::cmp::Reverse(end)))
    .copied()
    .unwrap_or((0, 0)))
}

pub fn get_words(_: &Lua, text: mlua::String) -> LuaResult<Vec<String>> {
    Ok(REGEX
        .find_iter(&text.to_string_lossy())
        .map(|m| m.as_str().to_string())
        .filter(|s| s.len() < 512)
        .collect::<HashSet<String>>()
        .into_iter()
        .collect())
}

// NOTE: skip_memory_check greatly improves performance
// https://github.com/mlua-rs/mlua/issues/318
#[mlua::lua_module(skip_memory_check)]
fn blink_cmp_fuzzy(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("init_db", lua.create_function(init_db)?)?;
    exports.set("destroy_db", lua.create_function(destroy_db)?)?;
    exports.set("access", lua.create_function(access)?)?;
    exports.set(
        "set_provider_items",
        lua.create_function(set_provider_items)?,
    )?;
    exports.set("fuzzy", lua.create_function(fuzzy)?)?;
    exports.set(
        "fuzzy_matched_indices",
        lua.create_function(fuzzy_matched_indices)?,
    )?;
    exports.set("get_keyword_range", lua.create_function(get_keyword_range)?)?;
    exports.set("guess_edit_range", lua.create_function(guess_edit_range)?)?;
    exports.set("get_words", lua.create_function(get_words)?)?;
    Ok(exports)
}
