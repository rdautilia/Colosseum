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

## Calcola il versore principale, dalla posizione del pedone alla destinazione
function versore_principale(pedone::Statopedone)
	norm = sqrt((pedone.lax-pedone.ladestx)^2+(pedone.lay-pedone.ladesty)^2)
	ex=(pedone.lax-pedone.ladestx)/norm
	ey=(pedone.lay-pedone.ladesty)/norm
	return  [ex, ey]
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
	return  [ex, ey]
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
