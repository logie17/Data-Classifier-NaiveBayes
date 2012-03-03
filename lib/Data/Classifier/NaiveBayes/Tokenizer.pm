package Data::Classifier::NaiveBayes::Tokenizer;
use Moose;
use Lingua::Stem::Snowball;
use 5.008008;

has 'stemmer' => (
    is => 'rw',
    lazy_build => 1,
    handles => ['stem_in_place']);

has 'stemming' => (
    is => 'rw',);

has lang => (
    is => 'rw',
    default => sub { 'en' });

sub _build_stemmer { return Lingua::Stem::Snowball->new(lang => $_[0]->lang) } 

sub words {
    my ($self, $string, $token_callback) = @_;

    my @words = map { lc $_ } $string =~ /(\w+(?:[-']\w+)*)/g;

    $self->stemmer->stem_in_place(\@words) if $self->stemming;

    if ( $token_callback && ref $token_callback eq 'CODE' ) {
        @words = map { &{$token_callback}($_) } @words;
    }

    return \@words;
}

1;
=head1 NAME

Data::Classifier::NaiveBayes

=head1 SYNOPSIS


=head1 DESCRIPTION

L<Data::Classifier::NaiveBayes> 

=head1 METHODS

=head1 SEE ALSO

L<Moo> 

=head1 AUTHOR

Logan Bell, C<< <logie@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012, Logan Bell

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
