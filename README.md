# hack-practice

Character frequency lookup tool over 青空文庫. Results can be refined by specifying a lower/upper bound on the year of publication.

Preprocessing step requires corpus data from [ryancahildebrandt/aozora_corpus](https://github.com/ryancahildebrandt/aozora_corpus) ([Kaggle dataset](https://www.kaggle.com/datasets/ryancahildebrandt/azbcorpus)) in `data` directory and automatically generates `data.db` in root directory.

Usage examples:

    hhvm lookup.hack 雲             # counts all occurrences across corpus
    hhvm lookup.hack 雲 \>= 1980    # counts all occurrences dated 1980 or later

List of valid operators:

- `=` : in works published during specified year 
- `\<`, `\<=` : in works published before (or during) specified year
- `\>`, `\>=` : in works published after (or during) specified year
- `?` : in works with unspecified date of publication
