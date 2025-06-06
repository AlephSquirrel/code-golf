-- earn() is called from earn_cheevos().
CREATE FUNCTION earn(INOUT earned cheevo[], cheevo cheevo, user_id int) AS $$
BEGIN
    INSERT INTO trophies VALUES (DEFAULT, user_id, cheevo)
             ON CONFLICT DO NOTHING;

    IF found THEN
        earned := array_append(earned, cheevo);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- earn_cheevos() is called from save_solution(), returns earned cheevos.
CREATE FUNCTION earn_cheevos(hole hole, lang lang, user_id int) RETURNS cheevo[] AS $$
#variable_conflict use_variable
DECLARE
    earned         cheevo[] := '{}'::cheevo[];
    holes          int;
    holes_for_lang hole[];
    langs_for_hole lang[];
BEGIN
    -----------
    -- Setup --
    -----------

    SELECT COUNT(DISTINCT stable_passing_solutions.hole) INTO holes
      FROM stable_passing_solutions
     WHERE stable_passing_solutions.user_id = user_id;

    SELECT array_agg(DISTINCT stable_passing_solutions.hole) INTO holes_for_lang
      FROM stable_passing_solutions
     WHERE stable_passing_solutions.lang    = lang
       AND stable_passing_solutions.user_id = user_id;

    SELECT array_agg(DISTINCT stable_passing_solutions.lang) INTO langs_for_hole
      FROM stable_passing_solutions
     WHERE stable_passing_solutions.hole    = hole
       AND stable_passing_solutions.user_id = user_id;

    ------------------------
    -- Hole/Lang Specific --
    ------------------------

    -- 💼 Interview Ready
    IF hole = 'fizz-buzz' THEN
        earned := earn(earned, 'interview-ready', user_id); END IF;
        
    -- 🧙 Alchemist
    IF hole = 'game-of-life' AND lang = 'elixir' THEN
        earned := earn(earned, 'alchemist', user_id); END IF;

    -- 🥣 Alphabet Soup
    SELECT COUNT(*) >= 3 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('c', 'd', 'j', 'k', 'r', 'v');
    IF hole = 'scrambled-sort' AND found THEN
        earned := earn(earned, 'alphabet-soup', user_id); END IF;

    -- 📚 Archivist
    SELECT COUNT(*) >= 3 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('basic', 'cobol', 'common-lisp', 'forth', 'fortran');
    IF hole = 'isbn' AND found THEN
        earned := earn(earned, 'archivist', user_id); END IF;

    -- 🪛 Assembly Required
    IF hole = 'seven-segment' AND lang = 'assembly' THEN
        earned := earn(earned, 'assembly-required', user_id); END IF;

    -- 🐦 Bird Is the Word
    SELECT COUNT(*) >= 3 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('awk', 'prolog', 'sql', 'swift', 'tcl', 'wren');
    IF hole = 'levenshtein-distance' AND found THEN
        earned := earn(earned, 'bird-is-the-word', user_id); END IF;

    -- ☕ Caffeinated
    SELECT COUNT(*) >= 2 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('civet', 'java', 'javascript');
    IF found THEN
        earned := earn(earned, 'caffeinated', user_id); END IF;

    -- 🎳 COBOWL
    IF hole = 'ten-pin-bowling' AND lang = 'cobol' THEN
        earned := earn(earned, 'cobowl', user_id); END IF;

    -- 👄 Dammit, Janet!
    IF hole = 'rock-paper-scissors-spock-lizard' AND lang = 'janet' THEN
        earned := earn(earned, 'dammit-janet', user_id); END IF;

    -- 🐘 ElePHPant in the Room
    IF lang = 'php' THEN
        earned := earn(earned, 'elephpant-in-the-room', user_id); END IF;

    -- 🏥 Emergency Room
    IF hole = '𝑒' AND lang = 'r' THEN
        earned := earn(earned, 'emergency-room', user_id); END IF;

    -- 😈 Evil Scheme
    IF hole IN ('evil-numbers', 'evil-numbers-long') AND lang = 'scheme' THEN
        earned := earn(earned, 'evil-scheme', user_id); END IF;

    -- 🐟 Fish ’n’ Chips
    IF hole = 'poker' AND lang = 'fish' THEN
        earned := earn(earned, 'fish-n-chips', user_id); END IF;

    -- 🏞️ Go Forth!
    IF langs_for_hole @> '{go,forth}' THEN
        earned := earn(earned, 'go-forth', user_id); END IF;

    -- 🍀 Happy-Go-Lucky
    IF holes_for_lang @> '{happy-numbers,lucky-numbers}' AND lang = 'go' THEN
        earned := earn(earned, 'happy-go-lucky', user_id); END IF;

    -- 🍯 Hextreme Agony
    IF hole = 'hexdump' AND lang = 'hexagony' THEN
        earned := earn(earned, 'hextreme-agony', user_id); END IF;

    -- 🧠 Inception
    IF hole = 'brainfuck' AND lang = 'brainfuck' THEN
        earned := earn(earned, 'inception', user_id); END IF;

    -- 💍 Jeweler
    IF hole = 'diamonds' AND langs_for_hole @> '{crystal,ruby}' THEN
        earned := earn(earned, 'jeweler', user_id); END IF;

    -- 😛 Just Kidding
    IF langs_for_hole @> '{j,k}' THEN
        earned := earn(earned, 'just-kidding', user_id); END IF;

    -- 🐑 Mary Had a Little Lambda
    SELECT COUNT(*) >= 3 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('clojure', 'coconut', 'common-lisp', 'haskell', 'scheme');
    IF hole = 'λ' AND found THEN
        earned := earn(earned, 'mary-had-a-little-lambda', user_id); END IF;

    -- 📴 Off-the-grid
    IF hole IN ('sudoku', 'sudoku-fill-in') AND lang = 'hexagony' THEN
        earned := earn(earned, 'off-the-grid', user_id); END IF;

    -- 🐍 Ouroboros
    IF hole = 'quine' AND lang = 'python' THEN
        earned := earn(earned, 'ouroboros', user_id); END IF;

    -- 🔠 Pangramglot
    IF hole = 'pangram-grep' AND pangramglot(langs_for_hole) = 26 THEN
        earned := earn(earned, 'pangramglot', user_id); END IF;

    -- 🎮 S-box 360
    IF hole = 'rijndael-s-box' AND lang IN ('c-sharp', 'f-sharp', 'powershell') THEN
        earned := earn(earned, 's-box-360', user_id); END IF;

    -- 🪞 Solve Quine
    IF hole = 'quine' THEN
        earned := earn(earned, 'solve-quine', user_id); END IF;

    -- 🎺 Sounds Quite Nice
    SELECT COUNT(*) >= 3 INTO found FROM UNNEST(langs_for_hole)
     WHERE unnest IN ('c', 'c-sharp', 'd', 'f-sharp');
    IF hole = 'musical-chords' AND found THEN
        earned := earn(earned, 'sounds-quite-nice', user_id); END IF;

    -- 🐪 Tim Toady
    IF langs_for_hole @> '{perl,raku}' THEN
        earned := earn(earned, 'tim-toady', user_id); END IF;

    -- 🗜 Under Pressure
    IF hole = 'pascals-triangle' AND lang = 'pascal' THEN
        earned := earn(earned, 'under-pressure', user_id); END IF;

    -- ❌ X-Factor
    IF hole = 'factorial-factorisation' AND lang = 'factor' THEN
        earned := earn(earned, 'x-factor', user_id); END IF;

    -------------------
    -- Miscellaneous --
    -------------------

    -- 🌈 Different Strokes
    IF (SELECT COUNT(DISTINCT solutions.code) > 1 FROM solutions
         WHERE solutions.user_id = user_id
           AND solutions.hole    = hole
           AND solutions.lang    = lang) THEN
        earned := earn(earned, 'different-strokes', user_id);
    END IF;

    -- 🔣 Polyglot
    IF array_length(langs_for_hole, 1) >= 12 THEN
        earned := earn(earned, 'polyglot', user_id); END IF;

    -- 🍖 Polyglutton
    IF array_length(langs_for_hole, 1) >= 24 THEN
        earned := earn(earned, 'polyglutton', user_id); END IF;

    -- 🕉️ Omniglot
    IF array_length(langs_for_hole, 1) >= 36 THEN
        earned := earn(earned, 'omniglot', user_id); END IF;

    -- 🍱 Omniglutton
    IF array_length(langs_for_hole, 1) >= 48 THEN
        earned := earn(earned, 'omniglutton', user_id); END IF;

    -----------------
    -- Progression --
    -----------------

    IF holes >=   1 THEN earned := earn(earned, 'hello-world',                user_id); END IF;
    IF holes >=   4 THEN earned := earn(earned, 'fore',                       user_id); END IF;
    IF holes >=  11 THEN earned := earn(earned, 'up-to-eleven',               user_id); END IF;
    IF holes >=  13 THEN earned := earn(earned, 'bakers-dozen',               user_id); END IF;
    IF holes >=  19 THEN earned := earn(earned, 'the-watering-hole',          user_id); END IF;
    IF holes >=  21 THEN earned := earn(earned, 'blackjack',                  user_id); END IF;
    IF holes >=  34 THEN earned := earn(earned, 'rule-34',                    user_id); END IF;
    IF holes >=  40 THEN earned := earn(earned, 'forty-winks',                user_id); END IF;
    IF holes >=  42 THEN earned := earn(earned, 'dont-panic',                 user_id); END IF;
    IF holes >=  50 THEN earned := earn(earned, 'bullseye',                   user_id); END IF;
    IF holes >=  60 THEN earned := earn(earned, 'gone-in-60-holes',           user_id); END IF;
    IF holes >=  69 THEN earned := earn(earned, 'cunning-linguist',           user_id); END IF;
    IF holes >=  80 THEN earned := earn(earned, 'phileas-fogg',               user_id); END IF;
    IF holes >=  86 THEN earned := earn(earned, 'x86',                        user_id); END IF;
    IF holes >=  90 THEN earned := earn(earned, 'right-on',                   user_id); END IF;
    IF holes >=  99 THEN earned := earn(earned, 'neunundneunzig-luftballons', user_id); END IF;
    IF holes >= 100 THEN earned := earn(earned, 'centenarian',                user_id); END IF;
    IF holes >= 107 THEN earned := earn(earned, 'busy-beaver',                user_id); END IF;
    IF holes >= 111 THEN earned := earn(earned, 'disappearing-act',           user_id); END IF;

    RETURN earned;
END;
$$ LANGUAGE plpgsql;
