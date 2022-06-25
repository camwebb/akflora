# Modeling akflora data as a graph


super : test

/home/cam/usr/agraph-server/bin/agraph-control --config agraph-server/lib/agraph.cfg start

/home/cam/usr/agraph-server/bin/agraph-control --config agraph-server/lib/agraph.cfg stop


      time stardog query -f TURTLE test1 q2.rq
      real  0m2.746s

      time agtool query --quiet --output-format turtle 10035/test q2.rq
      real  0m1.002s

agraph-control start
agraph-control stop



curl -O https://downloads.stardog.com/stardog/stardog-latest.zip
unzip stardog-latest.zip
mkdir stardog-server
export STARDOG_HOME=/home/cam/usr/stardog-server/

sudo pacman -S jre11-openjdk
archlinux-java status
export PATH="/usr/lib/jvm/java-11-openjdk/bin/:$PATH"

mv ~/Downloads/stardog-license-key.bin stardog-server

stardog-8.0.0/bin/stardog-admin server start
stardog-8.0.0/bin/stardog-admin db create -n test1
stardog data add --format turtle test1 data.ttl
stardog query -f TURTLE test1 q2.rq


## Neo4j

Very very slow to process data as cypher - forget it!
Slow to process data as CSV

