
type Pedone
      lax ::Float64
      lay::Float64
      lavx::Float64
      lavy::Float64
      ladestx::Float64
      ladesty::Float64
      
end
const PEDONE_DEFAULT = Pedone(0.1,0.1,0.1,0.1,0.1,0.1)

Pedone() = Pedone(PEDONE_DEFAULT)
\#ESEMPIO DI UN Array di 100 pedoni

popolazione = Array(Pedone,100)
for i in 1:100
   popolazione[i] = Pedone()
end

 function posizioni(stato)
       lex = []
       ley = []
       for i=1:N
           push!(lex,stato[i].lax)
       end
       for i=1:N
           push!(ley,stato[i].lay)
       end
       return transpose([lex ley])
       end
