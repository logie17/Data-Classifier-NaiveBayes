package Data::Classifier::NaiveBayes;
use Moose;
use MooseX::Types::LoadableClass qw(LoadableClass);
use List::Util qw(reduce sum);
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

has 'thresholds' => (
    is => 'rw',
    default => sub { {} });

sub _build_tokenizer { $_[0]->tokenizer_class->new }

sub cat_count {
    my ($self, $category) = @_;
    $self->categories->{$category};
}

sub total_count {
    my ($self) = @_;
    return sum values %{$self->categories};
}

sub doc_prob {
    my ($self, $text, $category) = @_;

    $self->tokenizer->words($text, sub{
        my $word = shift;
    });
}

sub word_prob {
    my ($self, $word, $cat ) = @_;
    return 0.0 if $self->cat_count($cat) == 0;
    sprintf("%.2f", $self->word_count($word, $cat) / $self->cat_count($cat));
}

sub word_count {
    my ($self, $word, $category) = @_;
    return 0.0 unless $self->words->{$word} && $self->words->{$word}->{$category};
    return sprintf("%.2f", $self->words->{$word}->{$category});
}

sub word_weighted_average {
    my ($self, $word, $cat ) = @_;
  
    my $weight = 1.0;
    my $assumed_prob = 0.5;

    # calculate current probability
    my $basic_prob = $self->word_prob($word, $cat);
  
    # count the number of times this word has appeared in all
    # categories
    my $totals = sum map { $self->word_count($word, $_) } keys $self->categories;
  
    # the final weighted average
    return ($weight * $assumed_prob + $totals * $basic_prob) / ($weight +
    $totals);
}

sub cat_scores {
    my ($self, $text) = @_;

    my $probs = {};

    for my $cat (keys %{$self->categories}) {
        $probs->{$cat} = $self->text_prop($text, $cat);
    }

    return sort { $a->[1] <=> $b->[1] } map { [$_, $probs->{$_} ] } keys %{$probs};
}

sub text_prop {
    my ($self, $text, $cat) = @_;
    my $cat_prob = $self->cat_count($cat) / $self->total_count;
    my $doc_prob = $self->doc_prob($text, $cat);
    return $cat_prob * $doc_prob;
}

sub classify {
    my ($self, $text, $default) = @_;

    my $max_prob = 0.0;
    my $best = undef;

    my $scores = $self->cat_scores($text);

    for my $score ( @{$scores} ) {
        my ( $cat, $prob ) = @{$score};
        if ( $prob > $max_prob ) {
            $max_prob = $prob;
            $best = $cat;
        }
    }

    return $default unless $best;
    my $threshold = $self->thresholds->{$best} || 1.0;

    for my $score ( @{$scores} ) {
        my ( $cat, $prob ) = @{$score};

        next if $cat == $best;
        return $default if $prob * $threshold > $max_prob;
    }

    return $best;
}

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
