#!/bin/bash

#Fonction de parsing
premiere_ligne=0
parse () {
    while IFS="," read id name mp str int def res spd luck race class rarity
    do
        if [[ $premiere_ligne -ne 0 ]]; then
            echo "$id $name $mp $str $int $def $res $spd $luck $race $class $rarity"

        else
            premiere_ligne=1
        fi

    done<"$FICHIER"

}


#Fonction de création du joueur :
creation_joueur () {
    #Récupération de la ligne correspondante
    FICHIER=fichiers_csv/players.csv
    JOUEUR=$(parse | head -n 1) #par défaut : Link

    #Récupération des stats
    NOM_JOUEUR=$(echo $JOUEUR | awk '{printf $2}')
    PVMAX_JOUEUR=$(echo $JOUEUR | awk '{ printf $3 }')
    FORCE_JOUEUR=$(echo $JOUEUR | awk '{ printf $5 }')
}


#Fonction de création de l'ennemi :
creation_ennemi () {
    #Récupération de la ligne correspondante
    FICHIER=fichiers_csv/enemies.csv
    ENNEMI=$(parse | tail -n 1) #par défaut : Bokoblin

    #Récupération des stats
    NOM_ENNEMI=$(echo $ENNEMI | awk '{ printf $2 }')
    PVMAX_ENNEMI=$(echo $ENNEMI | awk '{ printf $3 }')
    FORCE_ENNEMI=$(echo $ENNEMI | awk '{ printf $5 }')
}

#Création boss :
creation_boss (){
    #Récupération de la ligne correspondante
    FICHIER=fichiers_csv/bosses.csv
    ENNEMI=$(parse | head -n 1) #par défaut : Ganon

    #Récupération des stats
    NOM_ENNEMI=$(echo $ENNEMI | awk '{ printf $2 }')
    PVMAX_ENNEMI=$(echo $ENNEMI | awk '{ printf $3 }')
    FORCE_ENNEMI=$(echo $ENNEMI | awk '{ printf $5 }')
}


#creation_joueur
#creation_ennemi
#creation_boss

#####

#Dégâts infligés à l'ennemi
attaque_joueur()
{
    echo "Vous avez choisi d'attaquer "${NOM_ENNEMI}"."
    PV_ENNEMI=$((${PV_ENNEMI}-${FORCE_JOUEUR}))
    echo "Vous lui infligez "${FORCE_JOUEUR}" points de dégâts."

    if [[ $PV_ENNEMI -lt 0 ]];
    then
	PV_ENNEMI=0

    fi
    
    echo "Il lui reste "${PV_ENNEMI}" pv !"
    echo
}

#attaque_joueur

#Dégâts infligés au joueur
function attaque_ennemi()
{
    echo ${NOM_ENNEMI}" vous attaque."
    PV_JOUEUR=$((${PV_JOUEUR}-${FORCE_ENNEMI}))
    echo "Il vous inflige "${FORCE_ENNEMI}" points de dégâts."

    if [[ $PV_JOUEUR -lt 0 ]];
    then
        PV_JOUEUR=0

    fi
    
    echo "Il vous reste "${PV_JOUEUR}" PV !"
    echo
}

#attaque_ennemi


#####


heal (){
    #Le joueur récupère la moitié de ses pv maximum
    echo "Vous avez choisi de vous soigner."
    PV_RECUPERES=$(($PVMAX_JOUEUR/2))
    PV_JOUEUR=$(($PV_JOUEUR+$PV_RECUPERES))
    echo "Vous avez récupéré "${PV_RECUPERES}" PV !"

    #Si le joueur a plus de pv que le nombre de pv maximum, on les tronque
    if [[ $PV_JOUEUR -gt $PVMAX_JOUEUR ]]; then
	PV_JOUEUR=$PVMAX_JOUEUR

    fi

    echo "Vous avez désormais "${PV_JOUEUR}" PV."
    echo
}

#heal


#####

#Corps du progamme

#Création du joueur
creation_joueur

echo "Vous êtes enfin prêt, "${NOM_JOUEUR}"..."
echo "Vous entrez dans la tour..."
echo
echo


#Points de vie variables durant le combat
PV_JOUEUR=$PVMAX_JOUEUR

#echo "test"

#La tour a 10 étages
for ETAGE in $(seq 1 10) ;
do
    #echo "ÉTAGE NUMÉRO "$ETAGE
    
    if [[ $ETAGE -ne 10 ]]; #combat normal, pas de boss
    then
	#Création de l'ennemi
	creation_ennemi
	echo "========= COMBAT "${ETAGE}"========="
	#Points de vie variables durant le combat
	PV_ENNEMI=${PVMAX_ENNEMI}
	echo $NOM_ENNEMI" sauvage apparait."
	echo
	#Fin création de l'ennemi

    else #combat de boss
	#Création du boss
	creation_boss
	echo "========= COMBAT "${ETAGE}" - BOSS : "${NOM_ENNEMI}" ========="
	#Points de vie variables durant le combat
        PV_ENNEMI=${PVMAX_ENNEMI}
        echo "Vous arrivez au dernier étage de la tour. "$NOM_ENNEMI" apparait nonchalamment devant vous."
        echo
	#Fin création du boss
    fi
    

	
    #Le combat peut maintenant commencer
    while [[ ${PV_JOUEUR} -gt 0 ]] && [[ ${PV_ENNEMI} -gt 0 ]]
    do
	echo $NOM_JOUEUR" -------- "$PV_JOUEUR"/"$PVMAX_JOUEUR"PV"
	echo $NOM_ENNEMI" -------- " $PV_ENNEMI"/"$PVMAX_ENNEMI"PV"

	
        #Tour du joueur

	echo "Choisissez votre action :"
	echo "1 -------- Attaquer"
	echo "2 -------- Soin"

	read action
	if [[ $action -eq 1 ]];
	then
	    echo
	    attaque_joueur
	  
	    
	elif [[ $action -eq 2 ]];
	then
	    echo
	    heal
		
	else
	    echo "Choix impossible !"
	    continue #passe à la prochaine itération de la boucle while
	fi
	    

	#Si l'ennemi n'est pas mort suite à l'attaque du joueur :
	if [[ $PV_ENNEMI -gt 0 ]];
	then
	    #Tour de l'ennemi
	    echo 
	    attaque_ennemi
	fi

	#Test mort du joueur :
        #PV_JOUEUR=0
	    
	    
	#Si le joueur meurt suite à l'attaque de l'ennemi :
	if [[ $PV_JOUEUR -eq 0 ]];
	then
	    echo "Vous avez été vaincu... Revenez plus fort !"
	    exit #quitte le programme, la partie est finie
	fi
    done
    #Message de fin de combat
    if [[ $ETAGE -ne 10 ]]; #combat normal, pas de boss
    then
	echo
	echo "Bravo !"
	echo "Vous avez vaincu "${NOM_ENNEMI}" ! Vous passez à l'étage suivant."
	echo
	
    else #combat de boss
	echo
	echo "Félicitations !"
        echo "Après toutes ces épreuves, entraînements et efforts, vous avez enfin vaincu "${NOM_ENNEMI}" ! Hyrule est sauvée..."
	exit #quitte le programme, la partie est finie  
      fi
	
done
