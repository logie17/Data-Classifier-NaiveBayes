use Test::More;

use Data::Classifier::NaiveBayes;

my $classifier = Data::Classifier::NaiveBayes->new;

isa_ok $classifier->tokenizer, 'Data::Classifier::NaiveBayes::Tokenizer';

$classifier->train("foo", "The foo ran to the other side");

done_testing;
