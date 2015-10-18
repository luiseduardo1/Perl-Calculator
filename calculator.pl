#! /usr/bin/env perl
#Ajout de la librairie
use Getopt::Long;
use IO::Socket;

#Typedef de booleens
#use constant false => 0;
#use constant true => 1;

#Déclaration des variables
my $NUMBER_REGEX = "\d+";
#my $OPERATOR_REGEX = "(\+|\-|\*|\\)";

my $calc;
my $host;
my $input = "";
my $number_1;
my $number_2;
my $operator;
my $protocole = "tcp";
my $port;
my $number_connections = 0;

my $options = GetOptions("calc" => \$calc,
                         "port=i" => \$port,
                         "destination=s" => \$host);

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
            $number_1 = <$connection>;
            print $connection "Nombre 1 a ete reçu avec succes!\n";
            $number_2 = <$connection>;
            print $connection "Nombre 2 a ete reçu avec succes!\n";
            $operator = <$connection>;
            if ($operator ~~ ['-', '+', '/', '*'])
            {
                print $connection "Hello";
                #my $result = eval {"$number_1 $operator $number_2"};
                print $connection $result;
            }
            else
            {
                print $connection "Vous avez rentre un operateur incorrect.";
            }
			$input = <$connection>;
		}
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
