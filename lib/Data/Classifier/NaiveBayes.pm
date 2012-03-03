package Data::Classifier::NaiveBayes;
use Moose;
use MooseX::Types::LoadableClass qw(LoadableClass);
use 5.008008;

has tokenizer => (
    is => 'rw',
    lazy_build => 1);

has tokenizer_class => (
    is => 'ro',
    isa => LoadableClass,
    default => 'Data::Classifier::NaiveBayes::Tokenizer',
    coerce => 1);

has 'words' => (
    is => 'rw',
    default => sub { {} });

has 'categories' => (
    is => 'rw',
    default => sub { {} });

sub _build_tokenizer { $_[0]->tokenizer_class->new }

sub inc_cat {
    my ($self, $cat) = @_;
    $self->categories->{$cat} ||= 0;
    $self->categories->{$cat} += 1;
}

sub inc_word {
    my ($self, $word, $cat) = @_;
    $self->words->{$word} ||= {};
    $self->words->{$word}->{$cat} ||= 0;
    $self->words->{$word}->{$cat} += 1;
}

sub train {
    my ( $self, $cat, $string ) = @_;
    $self->tokenizer->words($string, sub{
        $self->inc_word(shift, $cat);    
    });
    $self->inc_cat($cat);
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
