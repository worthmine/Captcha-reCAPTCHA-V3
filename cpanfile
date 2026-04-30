requires 'perl', '5.008001';
requires 'JSON', '2.0';

recommends 'JSON::PP';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
