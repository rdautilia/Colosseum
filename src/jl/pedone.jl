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
