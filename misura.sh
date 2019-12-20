#!/bin/bash/

echo "inizia la misurazione"

MAXERR=25 
esatte=0 #per contaare il numero di stime esatte
errore=0 #per calcolare l'errore totale dato dalla somma degli errori per ogni singola stima
nerrori=0 #per contare il nuemro di stime errate
errmedio=0 #per calcolare l'errore medio
stime=0 #per contare il numero di stime fatte

echo "qui"

declare -A arraystime #array di stringhe per associare ad ogni client la stima del supervisor
declare -A arraysecret #array di stringhe per associare ad client il suo secret

echo "qui2"
for FILE in $@ ; do
	while read line; do
		RIGA=($line) #alla variabile di tipo stringa assegno volta per volta l'intera riga letta
		case $line in 
			(*"BASED "*) arraystime[${RIGA[4]}]=[${RIGA[2]}];; #associo il secret stimato dal supervisor al client 
			(*" SECRET "*) arraysecret[${RIGA[1]}]=[${RIGA[3]}];; #associo il secret effettivo del client all id del client stesso
		esac
	done<$FILE
	echo "finewhile"
done

for I in ${arraysecret[@]}; do
	Y=$(( arraystime[$I]-arraysecret[$I] )) #faccio la differenza tra il secret stimato dal supervisor per un client e il secret del client 
	if(( $Y<0 )); then
		Y=$((-$Y)) #se la stima e` negativa cambio il segno
	fi
	echo "y=" $Y
	if(( $Y < $MAXERR )); then #se la differenza e` minore di 25 allora incremento il numero di stime esatte
		esatte=$(( $esatte+1 ))
	fi
	if(( $Y>$MAXERR )); then 
		nerrori=$(( $nerrori+1 )) #se la differenza e` maggiore di 25 allora incremento il numero di stime errate
		echo "nerrori=" $nerrori
	fi
	errore=$(( $errore + $Y )) #l'errore totale e` dato da tutti gli errori per ogni singola stima
	stime=$(( $stime + 1)) #incremento il numero delle stime effettuate
done

errmedio=$(($errore/$nerrori)) #l'errore medio e` dato dall'errore totale diviso il numero di stime errate 

echo "stime effetuate: " $stime
echo "stime esatte: " $esatte
echo "errore medio: " ${errmedio}
