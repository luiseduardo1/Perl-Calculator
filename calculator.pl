#! /usr/bin/env perl
#
#Ajout de la librairie
use Getopt::Long;
use IO::Socket;
use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');

#Typedef de booleens
use constant false => 0;
use constant true => 1;

my $calc;
my $error_log;
my $file_name = "Error.log";
my $help;
my $host;
my $input;
my $number_1;
my $number_2;
my $operator;
my $protocole = "tcp";
my $port;
my $number_connections = 0;

sub getLoggingTime 
{
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my $nice_timestamp = sprintf("%04d/%02d/%02d %02d:%02d:%02d",
                                 $year+1900, $mon+1, $mday, $hour, $min, $sec);
    return $nice_timestamp;
}

sub writeError 
{
    my $file_name = @_[0];
    my $error_message = @_[1];
    open($error_log, ">>$file_name");
    print $error_log getLoggingTime();
    print $error_log "  $error_message";
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
    writeError($file_name, $error);
    die "$error";
}

if ($host and $calc)
{
    my $error = "Erreur: Vous ne pouvez utiliser l'option -d et -c simultanément.\n";
    writeError($file_name, $error);
    die "$error";
}
else
{
    if (!$host and !$calc)
    {
        my $error = "Erreur: Vous devez préciser une adresse de destination.\n";
        writeError($file_name, $error);
        die "$error";
    }
}

if ($calc)
{
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
            print $connection "Entrez le premier nombre:\n";
            chomp($number_1 = <$connection>);
            print $connection "Reçu: $number_1\n";
            while (!($number_1 =~ m{^(\d+(\.\d+)?)$}))
            {
                print $connection "Mauvais nombre. Recommencez.\n";
                chomp($number_1 = <$connection>);
                print $connection "Reçu: $number_1\n";
            }
            print $connection "Entrez le deuxième nombre:\n";
            chomp($number_2 = <$connection>);
            print $connection "Reçu: $number_2\n";
            while (!($number_2 =~ m{^(\d+(\.\d+)?)$}))
            {
                print $connection "Mauvais nombre. Recommencez.\n";
                chomp($number_2 = <$connection>);
                print $connection "Reçu: $number_2\n";
            }
            print $connection "Entrez l'opérateur \n";
            #chomp est necessaire pour que la comparaison de l'operateur fonctionne
            chomp($operator = <$connection>);
            print $connection "Reçu: $operator\n";
            while (not ($operator ~~["+", "-", "*", "/"]))
            {
                print $connection "Mauvais opérateur. Recommencez\n";
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
                print $connection "Résultat: $result\n";
            }
            print $connection "Si vous voulez quitter entrez \"quit\"\n";
            $input = <$connection>;
            $number_1 = "";
            $number_2 = "";
            $operator = "";
        }
		print $connection "Fermeture de la connection.\n";
        $input = "";
		close($connection);
	}
}
else
{
    my $connection = IO::Socket::INET->new(Proto => $proto,
                                           PeerAddr => $host,
                                           PeerPort => $port)
    or die "Impossible de se connecter sur le port $port à l'adresse $host";
    #On fait du multithread pour que les messages s'affiche instantanément et ne bloque pas les entrées
    async 
    {
        while (true) 
        {
            time.sleep(0.1);
            $input = <$connection>;
            print $input;
        }
    };
    while ($ligne ne "quit\n")
    {
        $ligne = <STDIN>;
        if ($ligne eq "quit\n")
        {
            print $connection "quit\r\n";
        }
        else
        {
            print $connection $ligne;
        }
    }
    print <$connection>;
    close ($connection);
}
