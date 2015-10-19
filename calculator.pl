#! /usr/bin/env perl
#Ajout de la librairie
use Getopt::Long;
use IO::Socket;

#Typedef de booleens
#use constant false => 0;
#use constant true => 1;

my $calc;
my $error_log;
my $help;
my $host;
my $input;
my $number_1;
my $number_2;
my $operator;
my $protocole = "tcp";
my $port;
my $number_connections = 0;

sub getLoggingTime {

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my $nice_timestamp = sprintf("%04d/%02d/%02d %02d:%02d:%02d",
                                 $year+1900, $mon+1, $mday, $hour, $min, $sec);
    return $nice_timestamp;
}

my $options = GetOptions("calc" => \$calc,
                         "port=i" => \$port,
                         "destination=s" => \$host,
                         "help" => \$help);

if ($help)
{
    die "utilisation: ./calculator.pl [-h] [-p Port] [-d Destination] [-c]\n\narguments optionnels:\n-h                  affiche ce message et quitte\n-p Port             le port du serveur \n-d Destination      l'adresse de destination\n-c                  si le serveur est en mode ecoute\n";
}

if (!$port)
{
    my $error = "Erreur: L'option -p est obligatoire.\n";
    open($error_log, ">>Error.log");
    print $error_log &getLoggingTime();
    print $error_log "  $error";
    die "$error";
}

if ($host and $calc)
{
    my $error = "Erreur: Vous ne pouvez utiliser l'option -d et -c simultanément.\n";
    open($error_log, ">>Error.log");
    print $error_log &getLoggingTime();
    print $error_log "  $error";
    die "$error";
}
else
{
    if (!$host and !$calc)
    {
        my $error = "Erreur: Vous devez preciser une adresse de destination.\n";
        open($error_log, ">>Error.log");
        print $error_log &getLoggingTime();
        print $error_log "  $error";
        die "$error";
    }
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
            #chomp est necessaire pour que la comparaison de l'operateur fonctionne
            chomp($operator = <$connection>);
            print $connection "Reçu: $operator\n";
            while (not ($operator ~~["+", "-", "*", "/"]))
            {
                print $connection "Mauvais operateur. Recommencez\n";
                chomp($operator = <$connection>);
                print $connection "Reçu: $operator\n";
            }
            my $result = eval "$number_1 $operator $number_2";
            if ($@)
            {
                print $connection "Un des nombres est invalide\n";
            }
            else
            {
                print $connection "Resultat: $result\n";
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
