#! /usr/bin/env perl
#Ajout de la librairie
use Getopt::Long;
use IO::Socket;

#Typedef de booleens
#use constant false => 0;
#use constant true => 1;

#Déclaration des variables
my $NUMBER_REGEX = "\d+";
my $OPERATOR_REGEX = "(+|-|*|/)";

my $calc;
my $host;
my $input;
my $number_1;
my $number_2;
my $operator;
my $protocole = "tcp";
my $port;
my $number_connections = 0;

my $options = GetOptions("calc" => \$calc,
                         "port=i" => \$port,
                         "destination=s" => \$host);
if (!$port)
{
    die "Vous devez preciser un numero de port.\n";
}

if (!$host)
{
    die "Vous devez preciser une adresse de destination.\n";
}

if ($calc)
{
	#Création de la connection pour l'écoute sur le port 3434
	#et avec le protocole tcp
	$serveur = IO::Socket::INET->new(Proto => $protocole,
                                     LocalPort => $port,
                                     Listen => SOMAXCONN,
                                     Reuse => 1)
	or die "Impossible de se connecter sur le port $port en localhost";
	while (my $connection = $serveur->accept())
	{
		++$number_connections;
		print "Connection $number_connections au serveur\n";
		print $connection "Bienvenue mon ami\n";
        while($input ne "quit\r\n")
        {
            #chomp removes trailing \r\n 
            chomp($number_1 = <$connection>);
            print $connection "Reçu: $number_1\n";
            chomp($number_2 = <$connection>);
            print $connection "Reçu: $number_2\n";
            #chomp est necessaire pour que le regex marche
            chomp($operator = <$connection>);
            print $connection "Reçu: $operator\n";
            #if ($operator =~ m/\Q$OPERATOR_REGEX\E/)
            if ($operator ~~ ["+", "-", "*", "/"])
            {
                my $result = eval "$number_1 $operator $number_2";
                if ($@)
                {
                    print $connection "Un des nombres est invalide\n";
                }
                else
                {
                    print $connection "Resultat: $result\n";
                }
            }
            else
            {
                print $connection "Vous avez rentre un operateur incorrect.\n";
            }
            print $connection "Si vous voulez quitter entrez \"quit\"\n";
            $input = <$connection>;
            $number_1 = "";
            $number_2 = "";
            $operator = "";
        }
		print $connection "Fermeture de la connection.\n";
        $input = "";
		#On ferme la connection
		close($connection);
	}
}
else
{
    my $connection = IO::Socket::INET->new(Proto => $proto,
                                           PeerAddr => $host,
                                           PeerPort => $port)
    or die "Impossible de se connecter sur le port $port à l'adresse $host";
    #Tant que l'utilisateur n'écris pas quit, on continue
    while ($ligne ne "quit\n")
    {
        #On attend que le serveur nous envoie une confirmation
        $input = <$connection>;
        #Affichage du message du serveur dans la console
        #de l'utilisateur
        print $input;
        #On attend que l'utilisateur entre une chaine
        $ligne = <STDIN>;
        #On envoie la chaine au serveur
        #Attention : Il faut prendre en considération
        #l'effet telnet sur le \n
        #Ainsi, on s'assure que notre serveur créé à l'exercice 4
        #fonctionne autant avec telnet qu'avec ce programme.
        if ($ligne eq "quit\n")
        {
            print $connection "quit\r\n";
        }
        else
        {
            print $connection $ligne;
        }
    }
    #Affichage de la dernière chaine envoyé par le serveur
    print <$connection>;
    #Fermeture de la connection
    close ($connection);
}
