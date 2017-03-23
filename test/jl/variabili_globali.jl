
# Variabili globali che sarebbe meglio eliminare
posizioni_prima = zeros(2,N)           # le posizioni dei pedoni al tempo t
#posizioni_dopo = rand(30.0:821.0,2,N)    # le posizioni dei pedoni al tempo t+dt
altre = [rand(0.0:0.0,1,N);rand(100.0:100.0,1,N)] # altre posizioni
posizioni_dopo = hcat([rand(100.0:100.0,1,N);rand(200.0:200.0,1,N)],altre) # le posizioni dei pedoni al tempo t+dt
velocita = zeros(2,N)                  # le posizioni dei pedoni al tempo t+dt
k = 0 ::Int64                       # Un iteratore
passo = 1.0 ::Float64                  # La dimensione di un passo
raggio = 0.5 ::Float64                 # Il raggio di non sovrapposizione dei pedoni
dimenpedone = 2.0 ::Float64                  # La dimensione del pedone 
scalax = 1.5 ::Float64                 # lunghezza del passo di un pedone nella direzione x
scalay = 1.5 ::Float64                 # lunghezza del passo di un pedone nella direzione y

mmm = 0.0 ::Float64                    # variabile di appoggio, ricontrollare se ci serve
