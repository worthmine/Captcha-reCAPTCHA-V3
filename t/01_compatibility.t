use strict;
use warnings;
use Test::More 0.98;

use Captcha::reCAPTCHA::V3;
my $rc = Captcha::reCAPTCHA::V3->new( secret => 'Dummy', sitekey => 'Dummy' );

{
    my @calls;

    no warnings 'redefine';
    local *Captcha::reCAPTCHA::V3::_has_http_tiny_ssl = sub { push @calls, 'http_tiny?'; 1 };
    local *Captcha::reCAPTCHA::V3::_has_lwp_https     = sub { push @calls, 'lwp?'; 1 };
    local *Captcha::reCAPTCHA::V3::_has_curl          = sub { push @calls, 'curl?'; 1 };
    local *Captcha::reCAPTCHA::V3::_verify_with_http_tiny = sub {
        push @calls, 'http_tiny';
        return q|{"success":true}|;
    };
    local *Captcha::reCAPTCHA::V3::_verify_with_lwp = sub {
        push @calls, 'lwp';
        return q|{"success":true}|;
    };
    local *Captcha::reCAPTCHA::V3::_verify_with_curl = sub {
        push @calls, 'curl';
        return q|{"success":true}|;
    };

    my $content = $rc->verify('dummy-response-token');
    is_deeply \@calls, [ 'http_tiny?', 'http_tiny' ], 'verify prefers HTTP::Tiny first';
    ok $content->{success}, 'HTTP::Tiny response is decoded';
}

{
    my @calls;

    no warnings 'redefine';
    local *Captcha::reCAPTCHA::V3::_has_http_tiny_ssl = sub { push @calls, 'http_tiny?'; 0 };
    local *Captcha::reCAPTCHA::V3::_has_lwp_https     = sub { push @calls, 'lwp?'; 1 };
    local *Captcha::reCAPTCHA::V3::_has_curl          = sub { push @calls, 'curl?'; 1 };
    local *Captcha::reCAPTCHA::V3::_verify_with_lwp = sub {
        push @calls, 'lwp';
        return q|{"success":true}|;
    };
    local *Captcha::reCAPTCHA::V3::_verify_with_curl = sub {
        push @calls, 'curl';
        return q|{"success":true}|;
    };

    my $content = $rc->verify('dummy-response-token');
    is_deeply \@calls, [ 'http_tiny?', 'lwp?', 'lwp' ], 'verify falls back to LWP after HTTP::Tiny';
    ok $content->{success}, 'LWP fallback response is decoded';
}

{
    my @calls;

    no warnings 'redefine';
    local *Captcha::reCAPTCHA::V3::_has_http_tiny_ssl = sub { push @calls, 'http_tiny?'; 0 };
    local *Captcha::reCAPTCHA::V3::_has_lwp_https     = sub { push @calls, 'lwp?'; 0 };
    local *Captcha::reCAPTCHA::V3::_has_curl          = sub { push @calls, 'curl?'; 1 };
    local *Captcha::reCAPTCHA::V3::_verify_with_curl = sub {
        push @calls, 'curl';
        return q|{"success":false,"error-codes":["invalid-input-response"]}|;
    };

    my $content = $rc->verify('dummy-response-token');
    is_deeply \@calls, [ 'http_tiny?', 'lwp?', 'curl?', 'curl' ], 'verify falls back to curl last';
    is $content->{'error-codes'}[0], 'invalid-input-response', 'curl fallback response is decoded';
}

{
    no warnings 'redefine';
    local *Captcha::reCAPTCHA::V3::_has_http_tiny_ssl = sub { 0 };
    local *Captcha::reCAPTCHA::V3::_has_lwp_https     = sub { 0 };
    local *Captcha::reCAPTCHA::V3::_has_curl          = sub { 0 };

    my $error = '';
    eval { $rc->verify('dummy-response-token'); 1 } or $error = $@;
    like $error, qr/HTTP::Tiny.*LWP::UserAgent.*curl/, 'verify croaks when no transport is available';
}

=ToDo

# These require culculated response value in javascript
# And to verify strictly, we have to set correct secret and sitekey

my $response;
$content = $rc->deny_by_score( response => $response, score => 0 );
$content = $rc->verify_or_die($response);

=cut

done_testing;
