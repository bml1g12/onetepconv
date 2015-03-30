#!/bin/bash
# Note that this script relies upon the existance of a filled species_array=() from a previous script.

mkdir -p ./ngwf_radius

cp ./input/$rootname.dat ./ngwf_radius/

# loop over each increased valence increment 

i=$min_NGWF_radius #i will be the counter for the current NGWF radius
while [ $(bc <<< "$i <= $max_NGWF_radius") -eq 1 ]
do

	if [ "$per_element" == "T" ]; then

		dir=${i}

		for species in "${species_array[@]}";
		do
			#create a string to label the element which is to be varied individually as per $per_element=T
			e=($species) 
			mkdir -p ./ngwf_radius/${e}_${dir}

			new_species_array=() 

			# create a new array containing the modified species strings
			for elem in "${species_array[@]}"; 
			do 
				element_tag=`echo $elem | awk {'print $1'}`
				element=`echo $elem | awk {'print $2'}` 
				atomic_number=`echo $elem | awk {'print $3'}`
				num_ngwf=`echo $elem | awk {'print $4'}`
				radius=`echo $elem | awk {'print $5'}`
				new_radius=$i 
		
				if [ "$elem" == "$species" ]; then
					
					new_species_array+=("$element_tag $element $atomic_number $num_ngwf $new_radius")
				else
					
					new_species_array+=("$element_tag $element $atomic_number $num_ngwf $radius")
				fi

			done
	
			#removes the block species section from the precursor input file
			awk '/^%block species$/{flag=1} /^%endblock species$/{flag=0} !flag' ./ngwf_radius/$rootname.dat > tmp && mv tmp ./ngwf_radius/$rootname.dat 
			sed -i -e "/^%endblock species$/d" ./ngwf_radius/$rootname.dat 

			#Adds the new species array to the .dat file
			echo -e "%block species" >> ./ngwf_radius/$rootname.dat
			for elem in "${new_species_array[@]}"; 
			do
				echo "$elem" >> ./ngwf_radius/$rootname.dat
			done
			echo "%endblock species" >> ./ngwf_radius/$rootname.dat

			###
			echo "Copying relevant input files (dat, recpot) to ./ngwf_radius/${e}_${dir}"
			cp ./recpot/*.recpot ./ngwf_radius/${e}_${dir}/
			cp ./ngwf_radius/$rootname.dat ./ngwf_radius/${e}_${dir}/  

		done

		i=`echo "$i + $NGWF_radius_spacing" | bc`

	else #vary all elements simultaneously

		dir=${i}
		mkdir -p ./ngwf_radius/$dir

		new_species_array=() 

		# create a new array containing the modified species strings
		for elem in "${species_array[@]}"; 
		do 
			element_tag=`echo $elem | awk {'print $1'}`
			element=`echo $elem | awk {'print $2'}` 
			atomic_number=`echo $elem | awk {'print $3'}`
			num_ngwf=`echo $elem | awk {'print $4'}`
			radius=`echo $elem | awk {'print $5'}`
			new_radius=$i
			new_species_array+=("$element_tag $element $atomic_number $num_ngwf $new_radius")
		done
	
		#removes the block species section from the precursor input file
		awk '/^%block species$/{flag=1} /^%endblock species$/{flag=0} !flag' ./ngwf_radius/$rootname.dat > tmp && mv tmp ./ngwf_radius/$rootname.dat 
		sed -i -e "/^%endblock species$/d" ./ngwf_radius/$rootname.dat 

		#Adds the new species array to the .dat file
		echo -e "%block species" >> ./ngwf_radius/$rootname.dat
		for elem in "${new_species_array[@]}"; 
		do
			echo "$elem" >> ./ngwf_radius/$rootname.dat
		done
		echo "%endblock species" >> ./ngwf_radius/$rootname.dat

		###
		echo "Copying relevant input files (dat, recpot) to ./ngwf_radius/$dir"
		cp ./recpot/*.recpot ./ngwf_radius/$dir/
		cp ./ngwf_radius/$rootname.dat ./ngwf_radius/$dir/  
		i=`echo "$i + $NGWF_radius_spacing" | bc`
	fi

done
