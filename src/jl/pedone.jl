const elle = 0.05 ::Float64		# Il raggio di non sovrapposizione dei pedoni

############################### QUESTA È IL TIPO STATOPEDONE
type Statopedone 
		lax ::Float64
		lay::Float64
		lavx::Float64
		lavy::Float64
		ladestx::Float64
		ladesty::Float64		
end

const STATOPEDONE_DEFAULT = Statopedone(0.1,0.1,1000.2,1000.2,0.1,0.1)
const STATOPEDONE_ZERO    = Statopedone(-10.0,-10.0,0.0,0.0,0.0,0.0)

## Calcola il versore della velocità del pedone, quindi della direzione in cui sta andando
function versore(ped::Statopedone)
	norm = sqrt(ped.lavx^2+ped.lavy^2)
	ex=(ped.lavx)/norm
	ey=(ped.lavy)/norm
	return  [ex ey]
end 
#####################
## Calcola il versore ortogonale al vettore velocità del pedone
function versore_ortogonale(ped::Statopedone)
	vx::Float64 = ped.lavy	
	vy::Float64 = -ped.lavx
	norm = sqrt(vx^2+vy^2)
	ex=(vx)/norm
	ey=(vy)/norm
	return  [ex ey]
end 
#####################
## Calcola il versore principale, dalla posizione del pedone alla destinazione
function versore_principale(pedone::Statopedone)
	norm = sqrt((pedone.ladestx-pedone.lax)^2+(pedone.ladesty-pedone.lay)^2)
	ex=(pedone.ladestx-pedone.lax)/norm
	ey=(pedone.ladesty-pedone.lay)/norm
	return  [ex ey]
end
##########

## Calcola il versore dal pedone j al pedone i
function versore_reciproco(pedj::Statopedone,pedk::Statopedone)
	norm = sqrt((pedj.lax-pedk.lax)^2+(pedj.lay-pedk.lay)^2)
	if norm == 0
		ex = 0.0
		ey = 0.0
	else
		ex=(pedj.lax-pedk.lax)/norm
		ey=(pedj.lay-pedk.lay)/norm
	end
	return  [ex ey]
end
#####################################

#### Funzione R di [TCS]
function laRTCS(s::Float64)
	a = 1.0
	l = 1.5
	D = 0.1
	return a*exp((l-s)/D)
end
##################
## Calcola la distanza tra due pedoni
function distanza_pedoni(pedi::Statopedone, pedj::Statopedone)
	a = sqrt((pedi.lax-pedj.lax)^2+(pedi.lay-pedj.lay)^2)
	return a
end
#####################################

#### Estrae la popolazione attiva, quella che si muove
function popolazione_attiva(popolazione::Array{Statopedone})
	a = filter(x->x !== STATOPEDONE_ZERO, stato_dopo)
	return a
end
#### Calcola il versore complessivo, che tiene conto dei contributi di tutti i pedoni
function versore_complessivo(pedi::Statopedone, popolazione::Array{Statopedone}) 
	ex = 0.0
	ey = 0.0
	for i in 1:length(popolazione)
		ex = ex + versore_reciproco(pedi, popolazione[i])[1]*laRTCS(pedone_piuvicino(pedi,popolazione_attiva(popolazione),1.5))
		ey = ey + versore_reciproco(pedi, popolazione[i])[2]*laRTCS(pedone_piuvicino(pedi,popolazione_attiva(popolazione),1.5))
	end
	ex = ex + versore_principale(pedi)[1]
	ey = ey + versore_principale(pedi)[2]
	return [ex ey]
end
#######################
## Costruisce l'array dei pedoni che si trovano nel rettangolo di fronte al pedone (vedi [TCS])
function ilJSet(ped::Statopedone, popolazione::Array{Statopedone})
	a=[]
	for i in 1:length(popolazione)
		if (sum(versore(ped) .* versore_reciproco(ped,popolazione[i])) <= 0.0  
			&& abs(sum(versore_ortogonale(ped) .* versore_reciproco(ped,popolazione[i])))<=elle/distanza_pedoni(ped,popolazione[i])
			&& distanza_pedoni(ped,popolazione[i])>0.0)
		push!(a,distanza_pedoni(ped,popolazione[i]))
		end
	end
	return a
end
###################
## calcola la distanza con il più vicono secondo [TCS]
function pedone_piuvicino(ped::Statopedone, popolazione::Array{Statopedone},l::Float64)
	a = ilJSet(ped, popolazione)
	if isempty(a)
		return 5.0
	else
		return minimum(a)
	end	
end
###################
## la velocità del pedone secondo il modello [TCS]
function velocitaTCS(ped::Statopedone,popolazione::Array{Statopedone},l::Float64, v0::Float64, laT::Float64 )
	s = pedone_piuvicino(ped,popolazione,l)
	a = min(v0,max(0.0,(s-l)/laT))
		return a
end
#####################
##### calcola la distanza dalla destinazione
function distanza_destinazione(ped::Statopedone)
	a = sqrt((ped.lax-ped.ladestx)^2+(ped.lay-ped.ladesty)^2)
	return a
end
##### scegli la prossima destinazione
function prossima_destinazione(ped::Statopedone)
	if in([ped.ladestx ped.ladesty],keys(ledestinazioni))
		dest = ledestinazioni[[ped.ladestx ped.ladesty]]
	else
		dest =[[ped.ladestx ped.ladesty]]
	end
		return dest[rand(1:length(dest))]
end
### Aggiunge un pedone ##########
function aggiungi_pedone()
a = rand(1:N)
#dest = scegli_destinazione();
orig = scegli_origine()
o1 = rand(orig[1]-5.0 : orig[1]+5.0)
o2 = rand(orig[2]-5.0 : orig[2]+5.0)
	if stato_dopo[a] == STATOPEDONE_ZERO && rand() < 0.1 #&& dest != orig
		stato_dopo[a] = Statopedone(o1,o2,10.02,10.02,orig[1],orig[2])
	end
end
	
#################################
