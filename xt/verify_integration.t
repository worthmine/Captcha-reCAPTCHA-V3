use strict;
use warnings;
use Test::More 0.98;

use Captcha::reCAPTCHA::V3;

my $secret   = $ENV{RECAPTCHA_TEST_SECRET};
my $response = $ENV{RECAPTCHA_TEST_RESPONSE};

if ( !$secret || !$response ) {
    plan skip_all => 'set RECAPTCHA_TEST_SECRET and RECAPTCHA_TEST_RESPONSE to run live verify test';
}

my $rc = Captcha::reCAPTCHA::V3->new( secret => $secret );
my $content = eval { $rc->verify($response) };

ok !$@, 'verify call does not die';
is ref($content), 'HASH', 'verify returns hashref';
ok exists $content->{success}, 'response includes success key';

# Optional strict check for environments that provide a fresh valid token.
if ( defined $ENV{RECAPTCHA_EXPECT_SUCCESS} && length $ENV{RECAPTCHA_EXPECT_SUCCESS} ) {
    my $expected = $ENV{RECAPTCHA_EXPECT_SUCCESS} ? 1 : 0;
    is $content->{success} ? 1 : 0, $expected, 'success matches RECAPTCHA_EXPECT_SUCCESS';
}

done_testing;
