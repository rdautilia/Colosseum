type Pedone
		lax ::Float64
		lay::Float64
		lavx::Float64
		lavy::Float64
		ladestx::Float64
		ladesty::Float64
		
end
const PEDONE_DEFAULT = Pedone(0.1,0.1,0.1,0.1,0.1,0.1)
const PEDONE_ZERO = Pedone(0.0,0.0,0.0,0.0,0.0,0.0)

Pedone() = Pedone(PEDONE_DEFAULT)
#ESEMPIO DI UN Array di 100 pedoni

popolazione = Array(Pedone,100)
for i in 1:100
	popolazione[i] = Pedone()
end