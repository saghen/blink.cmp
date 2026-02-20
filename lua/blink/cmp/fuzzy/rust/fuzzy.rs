// TODO: refactor this heresy

use crate::frecency::FrecencyDB;
use crate::keyword;
use crate::lsp_item::LspItem;
use crate::sort::Sort;
use frizbee::Match;
use mlua::prelude::*;
use mlua::FromLua;
use mlua::Lua;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(Clone)]
pub struct FuzzyOptions {
    pub match_suffix: bool,
    pub max_typos: u16,
    pub use_frecency: bool,
    pub use_proximity: bool,
    pub nearby_words: Option<Vec<String>>,
    pub snippet_score_offset: i32,
    pub sorts: Option<Vec<Sort>>,
}

#[derive(Clone)]
pub struct FuzzyMatch<'a> {
    pub provider_idx: u16,
    pub mtch: Match,
    pub item: &'a LspItem,
    pub score: i32,
}

impl FromLua for FuzzyOptions {
    fn from_lua(value: LuaValue, _lua: &'_ Lua) -> LuaResult<Self> {
        if let Some(tab) = value.as_table() {
            let match_suffix: bool = tab.get("match_suffix").unwrap_or_default();
            let max_typos: u16 = tab.get("max_typos").unwrap_or_default();
            let use_frecency: bool = tab.get("use_frecency").unwrap_or_default();
            let use_proximity: bool = tab.get("use_proximity").unwrap_or_default();
            let nearby_words: Option<Vec<String>> = tab.get("nearby_words").ok();
            let snippet_score_offset: i32 = tab.get("snippet_score_offset").unwrap_or_default();
            let sorts: Option<Vec<String>> = tab.get("sorts").ok();
            let sorts = sorts
                .map(|sorts| {
                    sorts
                        .iter()
                        .map(|s| s.try_into())
                        .collect::<Result<Vec<_>, _>>()
                })
                .transpose()?;

            Ok(FuzzyOptions {
                match_suffix,
                max_typos,
                use_frecency,
                use_proximity,
                nearby_words,
                snippet_score_offset,
                sorts,
            })
        } else {
            Err(mlua::Error::FromLuaConversionError {
                from: "LuaValue",
                to: "FuzzyOptions".to_string(),
                message: None,
            })
        }
    }
}

fn group_by_needle(
    line: &str,
    cursor_col: usize,
    haystack: &[String],
    match_suffix: bool,
) -> HashMap<String, Vec<(usize, String)>> {
    let mut items_by_needle: HashMap<String, Vec<(usize, String)>> = HashMap::new();
    let keyword_range = keyword::get_keyword_range(line, cursor_col, match_suffix);
    for (idx, item_text) in haystack.iter().enumerate() {
        let needle = keyword::guess_keyword(keyword_range, item_text, line);
        let entry = items_by_needle.entry(needle).or_default();
        entry.push((idx, item_text.to_string()));
    }
    items_by_needle
}

pub fn fuzzy<'a>(
    provider_idx: u16,
    line: &str,
    cursor_col: usize,
    haystack: &'a [LspItem],
    frecency: Option<&FrecencyDB>,
    opts: FuzzyOptions,
) -> Vec<FuzzyMatch<'a>> {
    let haystack_labels = haystack
        .iter()
        .map(|s| s.filter_text.clone().unwrap_or(s.label.clone()))
        .collect::<Vec<_>>();
    let config = frizbee::Config {
        max_typos: Some(opts.max_typos),
        sort: false,
        ..Default::default()
    };

    // Items may have different fuzzy matching ranges, so we split them up by needle
    let matches = group_by_needle(line, cursor_col, &haystack_labels, opts.match_suffix)
        .into_iter()
        // Match on each needle and combine
        .flat_map(|(needle, haystack)| {
            let mut matches = frizbee::match_list(
                &needle,
                &haystack
                    .iter()
                    .map(|(_, str)| str.as_str())
                    .collect::<Vec<_>>(),
                &config,
            );
            for mtch in matches.iter_mut() {
                mtch.index = haystack[mtch.index as usize].0 as u32;
            }
            matches
        })
        .collect::<Vec<_>>();

    // Get the score for each match, adding score_offset, frecency and proximity bonus
    let nearby_words: HashSet<String> = HashSet::from_iter(opts.nearby_words.unwrap_or_default());
    matches
        .into_iter()
        .map(|mtch| {
            let frecency_score = frecency
                .map(|frecency| {
                    frecency
                        .get_score(&(&haystack[mtch.index as usize]).into())
                        .unwrap_or(0.)
                        .min(6.)
                        .round() as i32
                })
                .unwrap_or(0);
            let nearby_words_score = if opts.use_proximity {
                nearby_words
                    .get(&haystack_labels[mtch.index as usize])
                    .map(|_| 2)
                    .unwrap_or(0)
            } else {
                0
            };
            let mut score_offset = haystack[mtch.index as usize].score_offset;
            // 15 = snippet
            // TODO: use an enum for the kind
            if haystack[mtch.index as usize].kind == 15 {
                score_offset += opts.snippet_score_offset;
            }

            FuzzyMatch {
                provider_idx,
                item: &haystack[mtch.index as usize],
                score: (mtch.score as i32) + frecency_score + nearby_words_score + score_offset,
                mtch,
            }
        })
        .collect::<Vec<_>>()
}

pub fn fuzzy_matched_indices(
    line: &str,
    cursor_col: usize,
    haystack: &[String],
    match_suffix: bool,
) -> Vec<Vec<usize>> {
    let config = frizbee::Config {
        max_typos: None,
        sort: false,
        ..Default::default()
    };
    let mut matches = group_by_needle(line, cursor_col, haystack, match_suffix)
        .into_iter()
        .flat_map(|(needle, haystack_with_indices)| {
            let haystack_strs: Vec<&str> = haystack_with_indices
                .iter()
                .map(|(_, h)| h.as_str())
                .collect();

            let match_indices = frizbee::match_list_indices(&needle, &haystack_strs, &config);

            haystack_with_indices
                .into_iter()
                .zip(match_indices)
                .map(|((idx, _), m)| (idx, m.indices))
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    matches.sort_by_key(|mtch| mtch.0);

    matches
        .into_iter()
        .map(|(_, matched_indices)| matched_indices)
        .collect::<Vec<_>>()
}
