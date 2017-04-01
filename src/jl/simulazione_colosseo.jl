using NearestNeighbors
using SFML
using AnimatedPlots
using JLD

# INIZIALIZZO LE COSTANTI
const N=3000 ::Int64				# Il numero di pedoni
const dt = 0.01 ::Float64			# Il passo di integrazione
const numero_iterazioni = 500		# Il numero di iterazioni della simulazione
const diag = sqrt(2) ::Float64		# diagonale
const raggio = 0.5 ::Float64		# Il raggio di non sovrapposizione dei pedoni
const dimenpedone = 2.1 ::Float64	# La dimensione del pedone	
const scalax = 1.2 ::Float64		# lunghezza del passo di un pedone nella direzione x
const scalay = 1.2 ::Float64		# lunghezza del passo di un pedone nella direzione y
const areacolosseo_coord = [314 256; 329 242; 359 223; 382 212; 419 204; 454 200; 489 204; 
523 211; 558 223; 597 245; 624 266; 659 306; 682 352; 688 403; 678 452; 651 444; 631 482; 
600 507; 562 525; 520 533; 485 531; 446 524; 412 510; 374 490; 344 462; 314 420; 300 384; 
300 351; 304 323; 312 299; 322 285] # L'area interna del colosseo
const destinazioni = [[479, 382],[352, 81],[39, 838],[5, 349]]
const origini = [[352, 81],[39, 838],[5, 349]]
include("vincoli.jl")

############### La funzione che seleziona a caso un punto di partenza ###########
function scegli_origine()
               a = rand(1:size(origini)[1])
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

#stato_prima = [] questo non ci serve, lo creiamo dopo con copy
stato_dopo  = Array(Statopedone,N)
#Lo stato prima non ci serve, viene creato dpo, quando servirà
#for i in 1:N
#	stato_prima[i] = Statopedone(STATOPEDONE_ZERO)
#end
for i in 1:N
	dest=scegli_destinazione();
	orig=scegli_origine();
	stato_dopo[i] = Statopedone(STATOPEDONE_ZERO)
end
###ROB> for i in 1:N
###ROB> 	dest=scegli_destinazione();
###ROB> 	orig=scegli_origine();
###ROB> 	stato_dopo[i] = Statopedone(rand(orig[1]-5.0 : orig[1]+5.0),rand(orig[2]-5.0 : orig[2]+5.0),10.02,10.02,dest[1],dest[2])
###ROB> end


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

# Variabili globali che sarebbe meglio eliminare
####ROB> posizioni_prima = zeros(2,N)				# le posizioni dei pedoni al tempo t
####ROB> altre = [rand(339.0:362.0,1,N);rand(75.0:93.0,1,N)] # altre posizioni
####ROB> posizioni_dopo = hcat([rand(-14.0:-4.0,1,N);rand(341.0:361.0,1,N)],altre) # le posizioni dei pedoni al tempo t+dt
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
const areacolosseo = ciclo_poligono(areacolosseo_coord) # Non capisco perché debba stare qui

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

# AGGIORNAMENTO DI UNA POSIZIONE A VELOCITA' COSTANTE
function aggiornamento(posingle::Statopedone)
	norm =sqrt((posingle.ladestx-posingle.lax)^2+(posingle.ladesty-posingle.lay)^2)
	#       dx = posingle[1] + scalax*(2*rand()-1.0) + 0.001*(180.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
	#       dy = posingle[2] + scalay*(2*rand()-1.0) + 0.001*(553.0-posingle[2])	#qui sarebbe meglio usare map()
				if (inpoly(posingle.lax,posingle.lay,areacolosseo) == 1
					)
			       dx = posingle.lax + (rand(-1.0:1.0)/scalax + posingle.lavx*(posingle.ladestx-posingle.lax))*dt	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			       dy = posingle.lay + (rand(-1.0:1.0)/scalay + posingle.lavy*(posingle.ladesty-posingle.lay))*dt	#qui sarebbe meglio usare map()
				else
					dx = posingle.lax + (rand(-1.0:1.0)/scalax + 10.0*posingle.lavx*(posingle.ladestx-posingle.lax)/norm)*dt	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			        dy = posingle.lay + (rand(-1.0:1.0)/scalax + 10.0*posingle.lavy*(posingle.ladesty-posingle.lay)/norm)*dt	#qui sarebbe meglio usare map()
			       
				end
	
       return Statopedone(dx,dy,posingle.lavx,posingle.lavy,posingle.ladestx,posingle.ladesty)
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
##################################################

# AGGORNAMENTO DEL VETTORE DELLE POSIZIONI
function aggiornamento_totale(stato)
		albero = KDTree(posizioni(stato))
	for i=1:N
		a = aggiornamento(stato[i])
		if (length(inrange(albero, [a.lax, a.lay], raggio, true)) == 0 && esterno(a.lax,a.lay,edifici_coord)==0)
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

	clear(window, SFML.Color(176,196,222))
	draw(window, sfondo)
	aggiungi_pedone()
	stato_prima = copy(stato_dopo)
	aggiornamento_totale(stato_dopo)
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
	# Draw the plots
for s in values(edifici_coord)
	draw(window, disegna_poligono(s))
end
	draw(window, mousepos_text)
	display(window)
end

