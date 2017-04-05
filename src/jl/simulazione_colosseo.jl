using NearestNeighbors
using SFML
using AnimatedPlots
using JLD

# INCLUDE LE NOSTRE LIBRERIE E I NOSTRI DATI
include("vincoli.jl")
include("pedone.jl")
include("nodi_fase0.jl")

# INIZIALIZZO LE COSTANTI
const GRAFO = 1
const VINCOLI = 1
const MOUSE = 1
const N=500 ::Int64				# Il numero di pedoni
const dt = 0.01 ::Float64			# Il passo di integrazione
const diag = sqrt(2) ::Float64		# diagonale
const dimenpedone = 2.1 ::Float64	# La dimensione del disegno pedone	
const scalax = 0.4 ::Float64		# lunghezza del passo di un pedone nella direzione x
const scalay = 0.4 ::Float64		# lunghezza del passo di un pedone nella direzione y

############### La funzione che seleziona a caso un punto di partenza ###########
function scegli_origine()
               a = rand(1:length(origini))
               b = origini[a]
               return b
       end
#########################################################################

############### La funzione che seleziona una destinazione a caso ###########
function scegli_destinazione()
               a = rand(1:size(destinazioni)[1])
               b = destinazioni[a]
               return b
       end
#########################################################################
########### Le variabili ###############
stato_dopo  = Array(Statopedone,N)
stato_dopo[1]=Statopedone(STATOPEDONE_DEFAULT)

for i in 1:N
	orig=scegli_origine();
	stato_dopo[i] = Statopedone(STATOPEDONE_ZERO)
end

velocita = zeros(2,N)						# le posizioni dei pedoni al tempo t+dt
k = 0 ::Int64								# Un iteratore
mmm = 0.0 ::Float64							# variabile di appoggio, ricontrollare se ci serve
fonti = Font("../../fonts/kenvector_future.ttf") :: Font

#########################################


######### Funzione che formatta il poligono ciclicamente #####
function ciclo_poligono(lista)
	c=[]
	for i=2:size(lista)[1]
			push!(c,lista[i-1,1])
			push!(c,lista[i-1,2])
			push!(c,lista[i,1])
			push!(c,lista[i,2])
	end
	push!(c,lista[size(lista)[1],1])
	push!(c,lista[size(lista)[1],2])
	push!(c,lista[1,1])
	push!(c,lista[1,2])
	cal=reshape(c,4,size(lista)[1])
			return transpose(cal)
end
##############################################################

######################## UNA FUNZIONE CHE CREA I POLIGONI DEGLI EDIFICI ###############
function disegna_poligono(polig_coord)
	the_shape = ConvexShape()
	set_pointcount(the_shape, size(polig_coord)[1])
	for i = 1:size(polig_coord)[1]
		set_point(the_shape, i-1, Vector2f(polig_coord[i,1], polig_coord[i,2]))
	end
	set_position(the_shape, Vector2f(0.0, 0.0))
	set_fillcolor(the_shape, SFML.transparent)
	set_outlinecolor(the_shape, SFML.green)
	set_outline_thickness(the_shape, 2)
	return the_shape
end
##########################################################################################

############ UNA FUNZIONE CHE VERIFICA CHE UN PUNTO NON SIA INTERNO AD ALCUN POLIGONO ###########
function esterno(lax, lay, polig_coord)
w = map(ciclo_poligono, values(polig_coord))
a = sum(map(x->inpoly(lax,lay,x),w))
	if a>0
		return 1 # interno
	else
		return 0 # esterno
	end
end
#####################
############ Conta i pedoni nel Colosseo ###########
function nel_colosseo(popolazione::Array{Statopedone})
	numero::Int64 = 0
	for pedone in popolazione
		numero = numero + esterno(pedone.lax,pedone.lay,areacolosseo_coord)
	end
	return numero
end
##################
# AGGIORNAMENTO DI UNA POSIZIONE A VELOCITA' COSTANTE
function aggiornamento(posingle::Statopedone)
	px::Float64 = 0.0
	py::Float64 = 0.0
	vx::Float64 = 0.0
	vy::Float64 = 0.0
#						lav =velocitaTCS(posingle,popolazione_attiva(stato_dopo), elle,5.2,1.0)
#						lav = 50.5
#						vx = lav*versore_complessivo(posingle,popolazione_attiva(stato_dopo))[1]
#						vy = lav*versore_complessivo(posingle,popolazione_attiva(stato_dopo))[2]
						px = posingle.lax  + posingle.lavx*versore_principale(posingle)[1]*dt + rand(0.0:1.0)*(rand(-1.0:1.0)/2.0)*scalax*versore_principale(posingle)[1]
						py = posingle.lay  + posingle.lavy*versore_principale(posingle)[2]*dt + rand(0.0:1.0)*(rand(-1.0:1.0)/2.0)*scalay*versore_principale(posingle)[2]
						if distanza_destinazione(posingle)<1.0
							destinazione = prossima_destinazione(posingle)
							posingle.ladestx = destinazione[1]
							posingle.ladesty = destinazione[2]
						end
		if posingle == STATOPEDONE_ZERO
			return posingle
		else
       		return Statopedone(px,py,posingle.lavx,posingle.lavy,posingle.ladestx,posingle.ladesty)
		end
end
################################

# CALCOLO DELLE VELOCITA'
function veloc(posprima,posdopo)
return posdopo-posprima
end
################################

# Tests a single point (px,py) against a closed polygon in edges = [x1 y1 x2 y2; x2 y2 x3 y3; x3 y3 x1 y1], the first point repeated as last point.
function inpoly(px,py,edges)
i = 0
for k=1:size(edges)[1]
 p1x = edges[k,1]
 p1y = edges[k,2]
 p2x = edges[k,3]
 p2y = edges[k,4]
 
 if (p1y < py) & (p2y < py) 
  continue
 end

 if (p1y >= py) & (p2y >= py) 
  continue
 end

 d = p2y - p1y
 s = (py-p1y)*(p2x-p1x)
 
 if d != 0
  sx = (s / d)+p1x
  if sx >= px
   i = i +1
  end
 end
end

return mod(i,2)
end
#####################################################
# La funzione che legge lo stato dei pedoni e restituisce la matrice 2XN delle posizioni
function posizioni(stato::Array{Statopedone})
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
##################################################

# AGGORNAMENTO DEL VETTORE DELLE POSIZIONI
function aggiornamento_totale(stato)
		albero = KDTree(posizioni(stato))
	for i=1:N
		a = aggiornamento(stato[i])
		if (length(inrange(albero, [a.lax, a.lay], elle, true)) == 0.0 && 	esterno(a.lax,a.lay,edifici_coord)==0.0)
			stato[i] = a
		end
	end
	return stato
end
#########################################


# COLORI
function colori(x)
	if x <0.33
#	        SFML.Color(1,168,21)
			SFML.Color(255,0,0)
	    elseif x >=0.33 && x< 0.66
#	        SFML.Color(231,202,0)
			SFML.Color(255,0,0)
	    else
	        SFML.Color(255,0,0)
	    end
end
#########################################
# disegna il grafico dei visitatori nel Colosseo
function grafico_visitatori(finestra)
	p1=Vector2f(945,220.0)
	p2=Vector2f(1250,220.0)
	linex = Line(p1, p2, 1)
	set_fillcolor(linex, SFML.Color(160,160,160))
	p1=Vector2f(945,220.0)
	p2=Vector2f(945,90.0)
	liney = Line(p1, p2, 1)
	set_fillcolor(liney, SFML.Color(160,160,160))
	draw(finestra, linex)
	draw(finestra, liney)

end
#################################################################################################
# LOAD THE TEXTURE FOR THE IMAGE ##### DA METTERE IN UNA FUNZIONE
texture = Texture("../../img/00-FASE0.jpg")
set_smooth(texture, true)
texture_size = get_size(texture)
######################################

# Create the text ##### DA METTERE IN UNA FUNZIONE
mousepos_text = RenderText()
#set_position(mousepos_text, Vector2f(texture_size.x+40, 20))
set_position(mousepos_text, Vector2f(940, 20))
set_string(mousepos_text, "Mouse Position: ")
set_color(mousepos_text, SFML.red)
set_charactersize(mousepos_text, 18)
##########################################
# Create the text ##### DA METTERE IN UNA FUNZIONE
pedattivi_text = RenderText()
#set_position(mousepos_text, Vector2f(texture_size.x+40, 20))
set_position(pedattivi_text, Vector2f(940, 40))
set_string(pedattivi_text, "Pedoni complessivi: ")
set_color(pedattivi_text, SFML.Color(153,255,153))
set_charactersize(pedattivi_text, 14)
##########################################
# Create the text ##### DA METTERE IN UNA FUNZIONE
nelcolosseo_text = RenderText()
#set_position(mousepos_text, Vector2f(texture_size.x+40, 20))
set_position(nelcolosseo_text, Vector2f(940, 60))
set_string(nelcolosseo_text, "Pedoni complessivi: ")
set_color(nelcolosseo_text, SFML.Color(153,255,153))
set_charactersize(nelcolosseo_text, 14)
##########################################

# Create the logo sprite and add the texture to it ##### DA METTERE IN UNA FUNZIONE
sfondo = Sprite()
set_texture(sfondo, texture)
set_position(sfondo, Vector2f(2, 2))
set_origin(sfondo, Vector2f(0,0)) #(texture_size.x/2, texture_size.y/2))
scale(sfondo, Vector2f(0.27, 0.27)) #L'immagine di sfondo viene scalata
###########################################

# LEGGO IL FILE CON I DATI
# posizioni = load("risultato_simulazione.jld")

# Create the SFML render window
settings = ContextSettings()
settings.antialiasing_level = 3
window = RenderWindow("Flussi Colosseo", 1400, 900)
# Create the plot window using the render window we created earlier
plotwindow = create_window(window)
###### set_vsync_enabled(window, true)

# Get the views (these are used for drawing
view = get_default_view(window)
plotview = plotwindow.view
set_framerate_limit(window, 120)
event = Event()

circles = CircleShape[]
for i = 1:2*N
	circle = CircleShape()
	set_radius(circle, dimenpedone)
	set_fillcolor(circle, SFML.red)
	set_origin(circle, Vector2f(0, 0))
	push!(circles, circle)
end

duc = 0 

while isopen(window)
	duc += 1
	sleep(0)
    # Check for any events
    while pollevent(window, event)
        if get_type(event) == EventType.CLOSED
            close(window)
        end
    end

# Get the mouse position and set the text
    mousepos = get_mousepos(window)
    set_string(mousepos_text, "Mouse Position: $(mousepos.x) $(mousepos.y)")

    if is_mouse_pressed(MouseButton.LEFT)
        set_string(mousepos_text, "Left click")
    end
    if is_mouse_pressed(MouseButton.RIGHT)
        set_string(mousepos_text, "Right click")
    end
######################

	clear(window, SFML.Color(64,64,64))
	draw(window, sfondo)
	aggiungi_pedone()
	stato_prima = copy(stato_dopo)
	aggiornamento_totale(stato_dopo)
	pa = length(popolazione_attiva(stato_dopo))
	pnc = (nel_colosseo(stato_dopo))
	
	set_string(pedattivi_text, "Popolazione: $pa")
	set_string(nelcolosseo_text, "Visitatori: $pnc")
#	vel = veloc(stato_dopo,stato_prima)	
	for i =1:N
#			mmm = norm(vel[:,i])/diag		
			set_position(circles[i], Vector2f(stato_dopo[i].lax, stato_dopo[i].lay))
#			ll=convert(Int64,round(255*norm(vel[:,i])) % 255)
#		set_fillcolor(circles[i], colori(mmm))
	end

	# Set the view for drawing the movements

	for i = 1:length(circles)
		draw(window, circles[i])
	end

	redraw(plotwindow)
	# Disegna il grafico dei visitatori
	grafico_visitatori(window)
	# Draw the plots
if VINCOLI == 1
	for s in values(edifici_coord)
		draw(window, disegna_poligono(s))
	end
end
if MOUSE == 1
	draw(window, mousepos_text)
end
	draw(window, pedattivi_text)
	draw(window, nelcolosseo_text)
if GRAFO ==1 
# disegna i nodi #####
	for k in keys(cn)
		draw(window, creanodo(k,cn[k]))
	end
######################
	disegna_link(window)
end
	display(window)
end

