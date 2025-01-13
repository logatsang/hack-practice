use namespace HH\Lib\Str;

enum Comp: int {
    NULL = 3;
    GEQ = 2;
    GTR = 1;
    ALL = 0;
    LSS = -1;
    LEQ = -2;
    EQUAL = -3;
    Default = 0;
}

function select_comp(string $x): Comp {
    switch ($x) {
        case '>':
            return Comp::GTR;
            break;
        case '>=':
            return Comp::GEQ;
            break;
        case '<':
            return Comp::LSS;
            break;
        case '<=':
            return Comp::LEQ;
            break;
        case '=':
            return Comp::EQUAL;
            break;
        case '?':
            return Comp::NULL;
            break;
        default:
            return Comp::Default;
            break;
    }
}

function get_id_from_title(SQLite3 $db, int $work_id): string {
    return $db->querysingle(Str\format(
        "SELECT title FROM metadata WHERE id == %d LIMIT 1", $work_id
    ));
}

function get_character_count(SQLite3 $db, int $char, Comp $comp = Comp::Default, int $year = 0): int {
    $query = 'SELECT SUM(C.count) FROM charcount C WHERE C.char == '.$char;

    if ($comp != Comp::ALL) {
        $query .= ' AND C.work in (SELECT M.id FROM metadata M WHERE M.year ';
        if ($comp == Comp::NULL) {
            $query .= 'IS NULL)';
        } else {
            if ($comp != Comp::EQUAL) $query .= ($comp > 0) ? '>' : '<';
            $query .= ($comp * $comp > 1) ? '=' : '';
            $query .= ' '.$year.')';
        }
    }
    
    return $db->querysingle($query);
}

<<__EntryPoint>>
function main(): void {
    $char_raw = (string) (vec(\HH\global_get('argv') as Container<_>)[1] ?? '');
    $char = \IntlChar::ord($char_raw);

    $opt1 = (string) (vec(\HH\global_get('argv') as Container<_>)[2] ?? 0);
    $opt2 = intval(vec(\HH\global_get('argv') as Container<_>)[3] ?? 0);

    $comp = select_comp($opt1);

    $condition_str = vec[" during", " before or during", " before", "", " after", " after or during", " of undefined year"][$comp + 3];
    if ($comp != Comp::NULL && $comp != Comp::ALL) {
        $condition_str .= ' '.$opt2;
    }

    $db = new SQLite3('data.db');
    $count = get_character_count($db, $char, $comp, $opt2);

    print(Str\format(
        "Count for %s (U+%s)%s: %d\n",
        $char_raw, strtoupper(dechex($char)),
        $condition_str, $count
    ));

    $db->close();
    exit(0);
}
