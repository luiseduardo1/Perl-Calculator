#! /usr/bin/env perl
#Ajout de la librairie
use Getopt::Long;
use IO::Socket;

#Déclaration des variables
my $NUMBER_REGEX = "\d+";
my $OPERATOR_REGEX = "[\(\)\+\-\*\\]";

my $calc;
my $number_1;
my $number_2;
my $operator;
my $protocole = "tcp";
my $port;
my $number_connections = 0;

my $options = GetOptions("port=i" => \$port,
			 "calc=bool" => \$calc);

if ($calc)
{
	#Création de la connection pour l'écoute sur le port 3434
	#et avec le protocole tcp
	$serveur = IO::Socket::INET->new( Proto => $protocole,
					  LocalPort => $port,
					  Listen => SOMAXCONN,
					  Reuse => 1)
	or die "Impossible de se connecter sur le port $port en localhost";
	while (my $connection = $serveur->accept())
	{
		my $input = "";
		$number_connections++;
		print "Connection $number_connections au serveur\n";
		print $connection "Bienvenue mon ami\n";
		while($input ne "quit\r\n")
		{
		    do
		    {
		    	$number_1 = <$connection>;
		    	$number_2 = <$connection>;
		    	$operator = <$connection>;
		    }
		    while(!($number_1 =~ $NUMBER_REGEX) &&
				  !($number_2 =~ $NUMBER_REGEX) &&
				  !($operator =~ $OPERATOR_REGEX));
		    my $result = eval {"$number_1 $operator $number_2"};
    		print $connection $result;
			$input = <$connection>;
		}
		#On ferme la connection
		close($connection);
	}
}
