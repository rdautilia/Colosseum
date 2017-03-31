############################### QUESTA È UNA PROVA 
type Statopedone 
		lax ::Float64
		lay::Float64
		lavx::Float64
		lavy::Float64
		ladestx::Float64
		ladesty::Float64
		
end

const STATOPEDONE_DEFAULT = Statopedone(0.1,0.1,0.1,0.1,0.1,0.1)
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
	a = 5.0
	l = 0.3
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
		ex = ex + versore_reciproco(pedi, popolazione[i])[1]*laRTCS(distanza_pedoni(pedi,popolazione[i]))
		ey = ey + versore_reciproco(pedi, popolazione[i])[2]*laRTCS(distanza_pedoni(pedi,popolazione[i]))
	end
	ex = ex + versore_principale(pedi)[1]
	ey = ey + versore_principale(pedi)[2]
	return [ex ey]
end
#######################
## Costruisce l'array dei pedoni che si trovano nel rettangolo di fronte al pedone (vedi [TCS])
function ilJSet(ped::Statopedone, popolazione::Array{Statopedone},l::Float64)
	a=[]
	for i in 1:length(popolazione)
		if (sum(versore(ped) .* versore_reciproco(ped,popolazione[i])) <= 0.0  
			&& abs(sum(versore_ortogonale(ped) .* versore_reciproco(ped,popolazione[i])))<=l/distanza_pedoni(ped,popolazione[i])
			&& distanza_pedoni(ped,popolazione[i])>0.0)
		push!(a,distanza_pedoni(ped,popolazione[i]))
		end
	end
	return a
end
### Aggiunge un pedone ##########
function aggiungi_pedone()
a = rand(1:N)
dest = scegli_destinazione();
orig = scegli_origine();
	if stato_dopo[a] == STATOPEDONE_ZERO && rand() < 0.5 && dest != orig
		stato_dopo[a] = Statopedone(rand(orig[1]-5.0 : orig[1]+5.0),rand(orig[2]-5.0 : orig[2]+5.0),10.02,10.02,dest[1],dest[2])
	end
end
	
#################################
