using NearestNeighbors
using SFML
using AnimatedPlots
using JLD

#MEMO: MODIFICARE IL 2N NEI FOR, CHE È INGUARDABILE
# INIZIALIZZO
const N=2000 ::Int64						# Il numero di pedoni
posizioni_prima = zeros(2,N)				# le posizioni dei pedoni al tempo t
#posizioni_dopo = rand(30.0:821.0,2,N)		# le posizioni dei pedoni al tempo t+dt
altre = [rand(0.0:800.0,1,N);rand(0.0:600.0,1,N)] # altre posizioni
posizioni_dopo = hcat([rand(0.0:924.0,1,N);rand(0.0:600.0,1,N)],altre) # le posizioni dei pedoni al tempo t+dt
velocita = zeros(2,N)						# le posizioni dei pedoni al tempo t+dt
const dt = 1.0 ::Float64					# Il passo di integrazione
const numero_iterazioni = 500				# Il numero di iterazioni della simulazione
k = 0 ::Int64								# Un iteratore
passo = 1.0 ::Float64						# La dimensione di un passo
raggio = 0.5 ::Float64						# Il raggio di non sovrapposizione dei pedoni
dimenpedone = 2.0 ::Float64						# La dimensione del pedone	
scalax = 1.5 ::Float64						# lunghezza del passo di un pedone nella direzione x
scalay = 1.5 ::Float64						# lunghezza del passo di un pedone nella direzione y

mmm = 0.0 ::Float64							# variabile di appoggio, ricontrollare se ci serve
const diag = sqrt(2) ::Float64				# diagonale

######### Funzione che formatta il poligono ciclicamente #####
function ciclo_poligono(lista)
	c=[]
	for i=2:size(lista)[1]
#	       	print(lista[i-1,1]," ",lista[i-1,2]," ",lista[i,1]," ",lista[i,2])
			push!(c,lista[i-1,1])
			push!(c,lista[i-1,2])
			push!(c,lista[i,1])
			push!(c,lista[i,2])
#	        print(";")
		end
	       	print(lista[size(lista)[1],1]," ",lista[size(lista)[1],2]," ",lista[1,1]," ",lista[1,2])
			push!(c,lista[size(lista)[1],1])
			push!(c,lista[size(lista)[1],2])
			push!(c,lista[1,1])
			push!(c,lista[1,2])

			cal=reshape(c,4,size(lista)[1])
			return transpose(cal)
end
##############################################################

###### POLIGONI DEGLI EDIFICI ##################
#colosseo=[0 0 100 0; 100 0 100 200; 100 200 50 50; 50 50 0 100; 0 100 0 0]
colosseo_coord=[410 497;426 504;442 507;465 510;493 511;516 508;542 500;562 491;
581 479;598 462;611 444;619 427;646 437;654 421;657 391;657 360;651 342;640 312;
622 290;608 268;590 250;564 232;543 219;514 205;498 200;484 197; 465 192; 438 190;
419 192; 402 193; 374 198; 353 205; 330 217; 311 231; 290 250; 274 268; 265 269;
260 313; 255 331; 287 336; 287 359; 293 385; 303 409; 314 429; 330 447; 349 465;
368 479; 390 490]
colosseo = ciclo_poligono(colosseo_coord)

g1_coord=[139 36; 201 66; 226 71; 241 70; 270 81; 273 71; 201 57; 159 41]
g1=ciclo_poligono(g1_coord)

g2_coord=[287 74; 379 93; 417 91; 431 96; 456 90; 465 98; 436 109; 432 125; 348 110; 348 102; 342 95; 284 81]
g2=ciclo_poligono(g2_coord)

g3_coord=[424 83; 429 89; 459 83; 476 100; 441 116; 440 126; 518 141; 529 147; 560 159; 597 172; 632 193; 682 218; 737 246; 734 238; 703 200; 553 105; 448 76]
g3=ciclo_poligono(g3_coord)

arco_costantino_coord =[121 482; 131 439; 201 454; 191 497]
arco_costantino=ciclo_poligono(arco_costantino_coord)

prato1_coord=[222 147; 230 127; 333 144; 315 182]
prato1=ciclo_poligono(prato1_coord)

prato2_coord=[179 256; 213 171; 287 199; 248 238; 229 275]
prato2=ciclo_poligono(prato2_coord)

venereroma_coord=[25 100; 193 165; 121 358; 25 329]
venereroma=ciclo_poligono(venereroma_coord)

metasudans_coord=[120 424; 175 271; 224 291; 212 339; 222 400; 212 446]
metasudans=ciclo_poligono(metasudans_coord)

palatino_coord=[23 783; 23 350; 100 377; 78 472; 80 488; 90 565; 83 652; 52 783]
palatino=ciclo_poligono(palatino_coord)

sangregorio_coord=[120 785; 130 760; 147 740; 177 709; 203 683; 235 659; 269 639; 307 625; 353 617; 413 619; 470 620; 544 624; 649 625; 684 645; 738 785]
sangregorio=ciclo_poligono(sangregorio_coord)

bordoest_coord=[608 230; 670 260; 700 280; 724 306; 734 330; 738 352; 737 376; 724 429; 693 504; 670 535; 622 565; 
570 573; 513 579; 451 578; 391 575; 343 576; 303 583; 262 594; 273 590; 221 614; 193 634; 157 660; 171 620; 185 580; 202 540; 206 524; 230 507; 420 561; 425 537;
503 543; 583 549; 638 536; 679 509; 702 465; 684 449; 693 402; 691 351; 676 307; 663 282; 643 254; 612 228]
bordoest=ciclo_poligono(bordoest_coord)

################################################

########## DISEGNO I POLIGONI DEGLI EDIFICI #########################
colosseo_shape = ConvexShape()
set_pointcount(colosseo_shape, size(colosseo_coord)[1])
for i = 1:size(colosseo_coord)[1]
	set_point(colosseo_shape, i-1, Vector2f(colosseo_coord[i,1], colosseo_coord[i,2]))
end
set_position(colosseo_shape, Vector2f(0.0, 0.0))
set_fillcolor(colosseo_shape, SFML.transparent)
set_outlinecolor(colosseo_shape, SFML.red)
set_outline_thickness(colosseo_shape, 2)

g1_shape = ConvexShape()
set_pointcount(g1_shape, size(g1_coord)[1])
for i = 1:size(g1_coord)[1]
	set_point(g1_shape, i-1, Vector2f(g1_coord[i,1], g1_coord[i,2]))
end
set_position(g1_shape, Vector2f(0.0, 0.0))
set_fillcolor(g1_shape, SFML.transparent)
set_outlinecolor(g1_shape, SFML.red)
set_outline_thickness(g1_shape, 2)

g2_shape = ConvexShape()
set_pointcount(g2_shape, size(g2_coord)[1])
for i = 1:size(g2_coord)[1]
	set_point(g2_shape, i-1, Vector2f(g2_coord[i,1], g2_coord[i,2]))
end
set_position(g2_shape, Vector2f(0.0, 0.0))
set_fillcolor(g2_shape, SFML.transparent)
set_outlinecolor(g2_shape, SFML.red)
set_outline_thickness(g2_shape, 2)

g3_shape = ConvexShape()
set_pointcount(g3_shape, size(g3_coord)[1])
for i = 1:size(g3_coord)[1]
	set_point(g3_shape, i-1, Vector2f(g3_coord[i,1], g3_coord[i,2]))
end
set_position(g3_shape, Vector2f(0.0, 0.0))
set_fillcolor(g3_shape, SFML.transparent)
set_outlinecolor(g3_shape, SFML.red)
set_outline_thickness(g3_shape, 2)

arco_costantino_shape = ConvexShape()
set_pointcount(arco_costantino_shape, size(arco_costantino_coord)[1])
for i = 1:size(arco_costantino_coord)[1]
	set_point(arco_costantino_shape, i-1, Vector2f(arco_costantino_coord[i,1], arco_costantino_coord[i,2]))
end
set_position(arco_costantino_shape, Vector2f(0.0, 0.0))
set_fillcolor(arco_costantino_shape, SFML.transparent)
set_outlinecolor(arco_costantino_shape, SFML.red)
set_outline_thickness(arco_costantino_shape, 2)

prato1_shape = ConvexShape()
set_pointcount(prato1_shape, size(prato1_coord)[1])
for i = 1:size(prato1_coord)[1]
	set_point(prato1_shape, i-1, Vector2f(prato1_coord[i,1], prato1_coord[i,2]))
end
set_position(prato1_shape, Vector2f(0.0, 0.0))
set_fillcolor(prato1_shape, SFML.transparent)
set_outlinecolor(prato1_shape, SFML.red)
set_outline_thickness(prato1_shape, 2)

prato2_shape = ConvexShape()
set_pointcount(prato2_shape, size(prato2_coord)[1])
for i = 1:size(prato2_coord)[1]
	set_point(prato2_shape, i-1, Vector2f(prato2_coord[i,1], prato2_coord[i,2]))
end
set_position(prato2_shape, Vector2f(0.0, 0.0))
set_fillcolor(prato2_shape, SFML.transparent)
set_outlinecolor(prato2_shape, SFML.red)
set_outline_thickness(prato2_shape, 2)

venereroma_shape = ConvexShape()
set_pointcount(venereroma_shape, size(venereroma_coord)[1])
for i = 1:size(venereroma_coord)[1]
	set_point(venereroma_shape, i-1, Vector2f(venereroma_coord[i,1], venereroma_coord[i,2]))
end
set_position(venereroma_shape, Vector2f(0.0, 0.0))
set_fillcolor(venereroma_shape, SFML.transparent)
set_outlinecolor(venereroma_shape, SFML.red)
set_outline_thickness(venereroma_shape, 2)

metasudans_shape = ConvexShape()
set_pointcount(metasudans_shape, size(metasudans_coord)[1])
for i = 1:size(metasudans_coord)[1]
	set_point(metasudans_shape, i-1, Vector2f(metasudans_coord[i,1], metasudans_coord[i,2]))
end
set_position(metasudans_shape, Vector2f(0.0, 0.0))
set_fillcolor(metasudans_shape, SFML.transparent)
set_outlinecolor(metasudans_shape, SFML.red)
set_outline_thickness(metasudans_shape, 2)

palatino_shape = ConvexShape()
set_pointcount(palatino_shape, size(palatino_coord)[1])
for i = 1:size(palatino_coord)[1]
	set_point(palatino_shape, i-1, Vector2f(palatino_coord[i,1], palatino_coord[i,2]))
end
set_position(palatino_shape, Vector2f(0.0, 0.0))
set_fillcolor(palatino_shape, SFML.transparent)
set_outlinecolor(palatino_shape, SFML.red)
set_outline_thickness(palatino_shape, 2)

sangregorio_shape = ConvexShape()
set_pointcount(sangregorio_shape, size(sangregorio_coord)[1])
for i = 1:size(sangregorio_coord)[1]
	set_point(sangregorio_shape, i-1, Vector2f(sangregorio_coord[i,1], sangregorio_coord[i,2]))
end
set_position(sangregorio_shape, Vector2f(0.0, 0.0))
set_fillcolor(sangregorio_shape, SFML.transparent)
set_outlinecolor(sangregorio_shape, SFML.red)
set_outline_thickness(sangregorio_shape, 2)

bordoest_shape = ConvexShape()
set_pointcount(bordoest_shape, size(bordoest_coord)[1])
for i = 1:size(bordoest_coord)[1]
	set_point(bordoest_shape, i-1, Vector2f(bordoest_coord[i,1], bordoest_coord[i,2]))
end
set_position(bordoest_shape, Vector2f(0.0, 0.0))
set_fillcolor(bordoest_shape, SFML.transparent)
set_outlinecolor(bordoest_shape, SFML.red)
set_outline_thickness(bordoest_shape, 2)

#####################################################################
# LOAD THE TEXTURE FOR THE IMAGE
texture = Texture("faseC.png")
set_smooth(texture, true)
texture_size = get_size(texture)
######################################
# Create the text
mousepos_text = RenderText()
set_position(mousepos_text, Vector2f(texture_size.x+40, 20))
set_string(mousepos_text, "Mouse Position: ")
set_color(mousepos_text, SFML.red)
set_charactersize(mousepos_text, 18)
##########################################


# Create the logo sprite and add the texture to it
sfondo = Sprite()
set_texture(sfondo, texture)
set_position(sfondo, Vector2f(20, 20))
set_origin(sfondo, Vector2f(0,0)) #(texture_size.x/2, texture_size.y/2))
scale(sfondo, Vector2f(1.0, 1.0))
###########################################

# AGGIORNAMENTO DI UNA POSIZIONE
function aggiornamento(posingle)
	#       dx = posingle[1] + scalax*(2*rand()-1.0) + 0.001*(180.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
	#       dy = posingle[2] + scalay*(2*rand()-1.0) + 0.001*(553.0-posingle[2])	#qui sarebbe meglio usare map()
	       dx = posingle[1] + scalax*(2*rand()-1.0) + 0.001*(180.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
	       dy = posingle[2] + scalay*(2*rand()-1.0) + 0.001*(553.0-posingle[2])	#qui sarebbe meglio usare map()
       return [dx,dy]
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

# AGGORNAMENTO DEL VETTORE DELLE POSIZIONI
function aggiornamento_totale(posizioni)
	albero = KDTree(posizioni)
		for i=1:2*N
			a = aggiornamento(posizioni[:,i])
			if (length(inrange(albero, a, raggio, true)) == 0 
				&& inpoly(a[1],a[2],colosseo) == 0 
				&& inpoly(a[1],a[2],g1) == 0 
				&& inpoly(a[1],a[2],g2) == 0 
				&& inpoly(a[1],a[2],g3) == 0 
				&& inpoly(a[1],a[2],arco_costantino) == 0 
				&& inpoly(a[1],a[2],prato1) == 0 
				&& inpoly(a[1],a[2],prato2) == 0 
				&& inpoly(a[1],a[2],venereroma) == 0
				&& inpoly(a[1],a[2],metasudans) == 0
				&& inpoly(a[1],a[2],palatino) == 0 
				&& inpoly(a[1],a[2],sangregorio) == 0 
				&& inpoly(a[1],a[2],bordoest) == 0 
				)
				posizioni[:,i] = a
			end
		end
	return posizioni
end
#########################################

# VARIABILI
fonti = Font("kenvector_future.ttf") :: Font
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
	#cycles = length(posizioni)
	posizioni_prima = copy(posizioni_dopo)
#	println("prima=",posizioni_prima,"\n")
	aggiornamento_totale(posizioni_dopo)
	vel = veloc(posizioni_dopo,posizioni_prima)	
#	println("primadopo=",posizioni_prima,"\n")
#	println("dopo=",posizioni_dopo,"\n")
	for i =1:2*N
			mmm = norm(vel[:,i])/diag		
			println(mmm)
			set_position(circles[i], Vector2f(posizioni_dopo[:,i][1], posizioni_dopo[:,i][2]))
			ll=convert(Int64,round(255*norm(vel[:,i])) % 255)
#		println(ll)
#		set_fillcolor(circles[i], SFML.Color(ll, 0, 0))
		set_fillcolor(circles[i], colori(mmm))
	end
	# Set the view for drawing the movements

	for i = 1:length(circles)
		draw(window, circles[i])
	end

	redraw(plotwindow)
	# Draw the plots
#####	draw(plotwindow)
	draw(window, colosseo_shape)
	draw(window, g1_shape)
	draw(window, g2_shape)
	draw(window, g3_shape)
	draw(window, arco_costantino_shape)
	draw(window, prato1_shape)
	draw(window, prato2_shape)
	draw(window, venereroma_shape)
	draw(window, metasudans_shape)
	draw(window, palatino_shape)
	draw(window, sangregorio_shape)
	draw(window, bordoest_shape)
	draw(window, mousepos_text)
	display(window)
end

