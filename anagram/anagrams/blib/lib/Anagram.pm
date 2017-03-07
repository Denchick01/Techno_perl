package Anagram;

use utf8;
#use open qw(:std :utf8);
use Encode qw(encode decode);
use strict;
use warnings;
use 5.10.0;
use bignum;
use DDP;
=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut


sub anagram {
	my @all_words = map {$_ = decode('utf8', $_); $_ =~ s/\s//g; lc($_)} @{$_[0]};
        my %group_anagram = ();
        my %result_anagram = ();
        for my $t_word (@all_words) {
                my $m_key = 0;
                for my $t_char (split "", $t_word) {
                        $m_key += ord($t_char);
                } 
                $m_key = $m_key * ($m_key - (length $t_word) ** 3);
                if (!(exists $group_anagram{$m_key})) {
                        $group_anagram{$m_key} = [$t_word];
                }
                else {
                        my $no_anagr = 0;
                        for my $t_anagr (@{$group_anagram{$m_key}}) {
                                if ($t_anagr eq $t_word) {
                                        $no_anagr = 1;
                                        last;
                                }
                        }
                        push @{$group_anagram{$m_key}}, $t_word if (!$no_anagr);
                }                                               
        }
        for my $t_anagr (values %group_anagram) {
                next if (scalar @$t_anagr <= 1);
		my @temp = map {encode('utf8', $_)} sort { $a cmp $b } @$t_anagr;
                $result_anagram{encode('utf8', $t_anagr->[0])} = [@temp];
        }
        return \%result_anagram;
}

1;
