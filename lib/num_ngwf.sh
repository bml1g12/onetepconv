#!/bin/bash

mkdir -p num_ngwf

cp ./input/$rootname.dat ./num_ngwf/

#Make a directory for NGWF radius'
mkdir -p ./num_ngwf/

#Create an array for species strings
species_array=() #in input file

# Read the input .dat and make an array containing the species strings
f=0
while read line
do
		case $line in
			"%block species") f=1; continue ;;
                        "%BLOCK SPECIES") f=1; continue ;;
                        "%endblock species") f=0 ;; 
                        "%ENDBLOCK SPECIES") f=0 ;;
		esac
		## copy the block species section to 'species_array'
		if [ "$f" -eq 1 ]; then # When it reaches the line tagged f=1 do the following
	        	species_line=`echo $line | awk {'print $1" "$2" "$3" "$4" "$5'} ` 
			species_array+=("$species_line")
		fi
done < ./num_ngwf/$rootname.dat


# loop over each increased number of NGWFs increment 
i=1
while [ $(bc <<< "$i <= $increased_ngwfs") -eq 1 ]
do

	if [ "$per_element" == "T" ]; then
		dir=${i}

		for species in "${species_array[@]}";
		do
			#create a string to label the element which is to be varied individually as per $per_element=T
			e=($species) 
			mkdir -p ./num_ngwf/${e}_${dir}

			new_species_array=() 

			# create a new array containing the modified species strings
			for elem in "${species_array[@]}"; 
			do 
				element_tag=`echo $elem | awk {'print $1'}`
				element=`echo $elem | awk {'print $2'}` 
				atomic_number=`echo $elem | awk {'print $3'}`
				num_ngwf=`echo $elem | awk {'print $4'}`
				new_ngwf=`expr $num_ngwf + $i` # add one to the default number of NGWFs up until you reach $increased_ngwfs
				radius=`echo $elem | awk {'print $5'}`
				if [ "$elem" == "$species" ]; then
					new_species_array+=("$element_tag $element $atomic_number $new_ngwf $radius")
				else
					new_species_array+=("$element_tag $element $atomic_number $num_ngwf $radius")
				fi
			done
	
			#removes the block species section from the precursor input file
			awk '/^%block species$/{flag=1} /^%endblock species$/{flag=0} !flag' ./num_ngwf/$rootname.dat > tmp && mv tmp ./num_ngwf/$rootname.dat 
			sed -i -e "/^%endblock species$/d" ./num_ngwf/$rootname.dat 

			#Adds the new species array to the .dat file
			echo -e "\n%block species" >> ./num_ngwf/$rootname.dat
			for elem in "${new_species_array[@]}"; 
			do
				echo "$elem" >> ./num_ngwf/$rootname.dat
			done
			echo -e "\n%endblock species" >> ./num_ngwf/$rootname.dat

			###


			echo "Copying relevant input files (dat, recpot) to ./num_ngwf/${e}_${dir}"
			cp ./recpot/*.recpot ./num_ngwf/${e}_${dir}/
			cp ./num_ngwf/$rootname.dat ./num_ngwf/${e}_${dir}/  
		done

		i=`echo "$i + 1" | bc`

	else #vary all elements simultaneously
		dir=${i}
		mkdir -p ./num_ngwf/$dir

		new_species_array=() 

		# create a new array containing the modified species strings
		for elem in "${species_array[@]}"; 
		do 
			element_tag=`echo $elem | awk {'print $1'}`
			element=`echo $elem | awk {'print $2'}` 
			atomic_number=`echo $elem | awk {'print $3'}`
			num_ngwf=`echo $elem | awk {'print $4'}`
			new_ngwf=`expr $num_ngwf + $i` # add one to the default number of NGWFs up until you reach $increased_ngwfs
			radius=`echo $elem | awk {'print $5'}`
			new_species_array+=("$element_tag $element $atomic_number $new_ngwf $radius")
		done
	
		#removes the block species section from the precursor input file
		awk '/^%block species$/{flag=1} /^%endblock species$/{flag=0} !flag' ./num_ngwf/$rootname.dat > tmp && mv tmp ./num_ngwf/$rootname.dat 
		sed -i -e "/^%endblock species$/d" ./num_ngwf/$rootname.dat 

		#Adds the new species array to the .dat file
		echo -e "\n%block species" >> ./num_ngwf/$rootname.dat
		for elem in "${new_species_array[@]}"; 
		do
			echo "$elem" >> ./num_ngwf/$rootname.dat
		done
		echo -e "\n%endblock species" >> ./num_ngwf/$rootname.dat

		###
		echo "Copying relevant input files (dat, recpot) to ./num_ngwf/$dir"
		cp ./recpot/*.recpot ./num_ngwf/$dir/
		cp ./num_ngwf/$rootname.dat ./num_ngwf/$dir/  
		i=`echo "$i + 1" | bc`
	fi
	
done


