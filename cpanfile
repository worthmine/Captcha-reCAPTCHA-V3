requires 'perl', '5.008001';
requires 'Module::Build::Tiny', '0.039';
requires 'JSON', '2.0';

recommends 'JSON::PP';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
