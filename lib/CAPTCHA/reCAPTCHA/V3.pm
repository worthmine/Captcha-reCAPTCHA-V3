package Captcha::reCAPTCHA::V3;
use 5.008001;
use strict;
use warnings;
use Carp;

use HTTP::Tiny;
use JSON qw(decode_json);

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    my %attr = @_;

    # Initialize the user agent object
    $self->{'ua'} = HTTP::Tiny->new(
        agent => __PACKAGE__ . '/' . $VERSION . ' (Perl)'
    );
    $self->{'sitekey'} = $attr{'sitekey'} || croak "missing param 'sitekey'";
    $self->{'secret'} = $attr{'secret'} || croak "missing param 'secret'";
    $self->{'widget_api'} = 'https://www.google.com/recaptcha/api.js?render='. $attr{'sitekey'};
    $self->{'verify_api'} = 'https://www.google.com/recaptcha/api/siteverify';

    return $self;
}

sub verify {
    my $self = shift;
    my $response = shift;
    croak "Extra arguments have been set." if @_;
 
    my $params = {
        secret    => $self->{'secret'},
        response  => $response || croak "missing response token",
    };
 
    my $res = $self->{'ua'}->post_form( $self->{'verify_api'}, $params );

    if($res->{'success'}) {
        return decode_json($res->{'content'});
    }else{
        croak "something wrong to post by HTTP::Tiny";
    }
}

sub script4head {
    my $self = shift;
    my %attr = @_;
    my $action = $attr{'action'} || 'homepage';
    my $id =  $self->get_element_id();
    return <<"EOL";
    <script src="//code.jquery.com/jquery-latest.js"></script>
    <script src="$self->{'widget_api'}"></script>
    <script>
    grecaptcha.ready(function() {
        grecaptcha.execute('$self->{'sitekey'}', {action: '$action'}).then(function(token) {
            \$("#$id").val(token);
//            console.log(token);
        });
    });
    </script>
EOL
}

sub input4form {
    my $self = shift;
    my %attr = @_;
    my $name = $attr{'name'} || 'reCAPTCHA_Token';
    my $id =  $self->get_element_id();
    return qq|<input type="hidden" name="$name" id="$id" />|;
}

sub get_element_id {
    my $self = shift;
    return 'recaptcha_' . substr( $self->{'sitekey'}, 0, 10 );
}

1;
__END__
 
=encoding utf-8

=head1 NAME

Captcha::reCAPTCHA::V3 - It's new $module

=head1 SYNOPSIS

    use Captcha::reCAPTCHA::V3;

=head1 DESCRIPTION

CAPTCHA::reCAPTCHA::V3 is ...

=head1 LICENSE

Copyright (C) worthmine.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

worthmine E<lt>worthmine@cpan.orgE<gt>

=cut

