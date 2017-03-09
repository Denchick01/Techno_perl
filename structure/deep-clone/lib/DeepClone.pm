package DeepClone;

use 5.010;
use strict;
use warnings;
use DDP;
=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

my %ref_stack = ();
sub pack_hash($);
sub pack_array($);

sub clone {
	my $struct = shift;
        my %ref_ex = (  
                        HASH   =>   \&pack_hash,
                        ARRAY  =>   \&pack_array,
                        CODE   =>   sub{sub{}},
                        SCALAR =>   sub{sub{}}
        );
	return $struct if (!ref($struct)); 

        my $temp = $ref_ex{ref($struct)}($struct);
        if (ref ($temp) eq "CODE") {
                return undef;
        }
        else {
                return $temp;
        }
}

sub pack_array($)
{
        my @array_struct = @{$_[0]};
        my @new_struct = ();
        for (my $it = 0; $it < scalar @array_struct; ++$it) {
                if (ref($array_struct[$it]) eq "CODE" ||
                ref($array_struct[$it]) eq "SCALAR") {
                        return sub {}; 
                }
                elsif (ref($array_struct[$it])) {
			if ((exists $ref_stack{$array_struct[$it]})) {
                        	$new_struct[$it] = $array_struct[$it];
			}
			else {
                        	$ref_stack{$array_struct[$it]} = 1;
                        	return sub {} if (!($new_struct[$it] = clone($array_struct[$it])));
                	}
		}
                else {
                        $new_struct[$it] = $array_struct[$it];
                }
        }
        return \@new_struct;            
}

sub pack_hash($)
{
        my %hash_struct = %{$_[0]};
        my %new_struct = ();
        for my $t_key (keys %hash_struct) {
                if (ref($hash_struct{$t_key}) eq "CODE" ||
                ref($hash_struct{$t_key}) eq "SCALAR") {
                        return sub {}; 
                }
                elsif (ref($hash_struct{$t_key})) {
			if ((exists $ref_stack{$hash_struct{$t_key}})) {
                        	$new_struct{$t_key} = $hash_struct{$t_key};
                	}
			else {
                        	$ref_stack{$hash_struct{$t_key}} = 1;
                        	return sub {} if (!($new_struct{$t_key} = clone($hash_struct{$t_key})));
			}
                }
                else {
                        $new_struct{$t_key} = $hash_struct{$t_key};
                }
        }
        return \%new_struct;            
}
1;      

