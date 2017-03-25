using NearestNeighbors
using SFML
using AnimatedPlots
using JLD

# INIZIALIZZO LE COSTANTI
const N=100 ::Int64				# Il numero di pedoni
const dt = 1.0 ::Float64			# Il passo di integrazione
const numero_iterazioni = 500		# Il numero di iterazioni della simulazione
const diag = sqrt(2) ::Float64		# diagonale
const passo = 1.0 ::Float64			# La dimensione di un passo
const raggio = 1.8 ::Float64		# Il raggio di non sovrapposizione dei pedoni
const dimenpedone = 1.0 ::Float64	# La dimensione del pedone	
const scalax = 1.1 ::Float64		# lunghezza del passo di un pedone nella direzione x
const scalay = 1.1 ::Float64		# lunghezza del passo di un pedone nella direzione y
const areacolosseo_coord = [314 256; 329 242; 359 223; 382 212; 419 204; 454 200; 489 204; 
523 211; 558 223; 597 245; 624 266; 659 306; 682 352; 688 403; 678 452; 651 444; 631 482; 
600 507; 562 525; 520 533; 485 531; 446 524; 412 510; 374 490; 344 462; 314 420; 300 384; 
300 351; 304 323; 312 299; 322 285] # L'earea interna

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
const STATOPEDONE_ZERO = Statopedone(0.0,0.0,0.0,0.0,0.0,0.0)
posizioni_prima = Array(Statopedone,N)
posizioni_dopo = Array(Statopedone,N)

for i in 1:100
	posizioni_prima[i] = Statopedone(STATOPEDONE_ZERO)
end

for i in 1:100
	posizioni_dopo[i] = Statopedone(STATOPEDONE_DEFAULT)
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

###### DICTIONARY POLIGONI DEGLI EDIFICI ##################
const edifici_coord = Dict{String, Array}(
"colosseoa_coord" => [373 203;390 198; 410 192; 440 190; 464 190; 487 191; 507 194; 537 202; 567 213; 594 229; 615 244; 642 272; 662 298; 678 325; 693 357; 698 356;
698 411; 699 444; 691 459; 679 455; 687 422; 689 402; 688 387; 687 374; 684 358; 679 344; 673 330; 664 317; 657 305; 648 292; 638 280; 627 270; 615 259; 603 250;
590 242; 577 234; 561 224; 548 220; 532 212; 518 210; 502 206; 485 204; 471 202; 455 201; 441 201; 425 202; 409 206; 397 209; 380 213], # L'emiciclo a
"colosseob_coord" => [659 449; 652 464; 643 478; 636 488; 625 498; 616 506; 605 514; 595 519; 583 524; 559 534; 544 537; 530 539; 518 541; 502 541; 489 540; 473 538; 
461 536; 444 531; 447 525; 465 528; 477 531; 491 533; 503 533; 518 533; 532 533; 545 531; 559 528; 573 523; 583 518; 593 514; 604 507; 615 502; 624 491; 631 483;
638 475; 644 464; 649 451; 650 444], # L'emiciclo b
"colosseoc_coord" => [409 519; 395 511; 381 503; 371 496; 361 488; 349 478; 340 468; 330 459; 322 448; 313 432; 309 423; 303 411; 298 400; 295 386; 294 374;
293 360; 293 344; 261 342; 264 323; 269 305; 276 289; 281 277; 288 266; 323 288; 315 303; 311 312; 307 325; 303 338; 301 350; 301 362; 300 373; 302 387;
307 400; 315 421; 329 443; 336 454; 347 466; 367 485; 388 498; 399 505; 412 510], # L'emiciclo c
"colosseod_coord" => [305 245; 321 230; 335 221; 355 223; 340 233; 326 242; 314 254] # L'emiciclo d
###ROB>"g1_coord" => [139 36; 201 66; 226 71; 241 70; 270 81; 273 71; 201 57; 159 41],
###ROB>"g2_coord" => [287 74; 379 93; 417 91; 431 96; 456 90; 465 98; 436 109; 432 125; 348 110; 348 102; 342 95; 284 81],
###ROB>"g3_coord" => [424 83; 429 89; 459 83; 476 100; 441 116; 440 126; 518 141; 529 147; 560 159; 597 172; 632 193; 682 218; 737 246; 734 238; 703 200; 553 105; 448 76],
###ROB>"arcoCostantino_coord" => [121 482; 131 439; 201 454; 191 497],
###ROB>"prato1_coord" => [222 147; 230 127; 333 144; 315 182],
###ROB>"prato2_coord" => [179 256; 213 171; 287 199; 248 238; 229 275],
###ROB>"venereroma_coord" => [25 100; 193 165; 121 358; 25 329],
###ROB>"metasudans_coord" => [120 424; 175 271; 224 291; 212 339; 222 400; 212 446],
###ROB>"palatino_coord" => [23 783; 23 350; 100 377; 78 472; 80 488; 90 565; 83 652; 52 783],
###ROB>"sangregorio_coord" => [120 785; 130 760; 147 740; 177 709; 203 683; 235 659; 269 639; 307 625; 353 617; 413 619; 470 620; 544 624; 649 625; 684 645; 738 785],
###ROB>"bordoest_coord" => [608 230; 670 260; 700 280; 724 306; 734 330; 738 352; 737 376; 724 429; 693 504; 670 535; 622 565; 
###ROB>570 573; 513 579; 451 578; 391 575; 343 576; 303 583; 262 594; 273 590; 221 614; 193 634; 157 660; 171 620; 185 580; 202 540; 206 524; 230 507; 420 561; 425 537;
###ROB>503 543; 583 549; 638 536; 679 509; 702 465; 684 449; 693 402; 691 351; 676 307; 663 282; 643 254; 612 228]
)

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
#################################################################################################
# LOAD THE TEXTURE FOR THE IMAGE
texture = Texture("../../img/00-FASE0.jpg")
set_smooth(texture, true)
texture_size = get_size(texture)
######################################

# Create the text
mousepos_text = RenderText()
#set_position(mousepos_text, Vector2f(texture_size.x+40, 20))
set_position(mousepos_text, Vector2f(940, 20))
set_string(mousepos_text, "Mouse Position: ")
set_color(mousepos_text, SFML.red)
set_charactersize(mousepos_text, 18)
##########################################


# Create the logo sprite and add the texture to it
sfondo = Sprite()
set_texture(sfondo, texture)
set_position(sfondo, Vector2f(2, 2))
set_origin(sfondo, Vector2f(0,0)) #(texture_size.x/2, texture_size.y/2))
scale(sfondo, Vector2f(0.27, 0.27)) #L'immagine di sfondo viene scalata
###########################################

# AGGIORNAMENTO DI UNA POSIZIONE
function aggiornamento(posingle)
	#       dx = posingle[1] + scalax*(2*rand()-1.0) + 0.001*(180.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
	#       dy = posingle[2] + scalay*(2*rand()-1.0) + 0.001*(553.0-posingle[2])	#qui sarebbe meglio usare map()
				if (inpoly(posingle[1],posingle[2],areacolosseo) == 1
					)
			       dx = posingle[1] + 2*scalax*(2*rand()-1.0) + 0.001*(402.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			       dy = posingle[2] + 2*scalay*(2*rand()-1.0) + 0.001*(592.0-posingle[2])	#qui sarebbe meglio usare map()
				else
					dx = posingle[1] + scalax*(2*rand()-1.0) + 0.01*(326.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			        dy = posingle[2] + scalay*(2*rand()-1.0) + 0.01*(273.0-posingle[2])	#qui sarebbe meglio usare map()
			       
				end
	
       return [dx,dy]
end
################################
# AGGIORNAMENTO DI UNA POSIZIONE
function aggiornamento_nuovo(posingle::Statopedone)
	#       dx = posingle[1] + scalax*(2*rand()-1.0) + 0.001*(180.0-posingle[1])	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
	#       dy = posingle[2] + scalay*(2*rand()-1.0) + 0.001*(553.0-posingle[2])	#qui sarebbe meglio usare map()
				if (inpoly(posingle.lax,posingle.lay,areacolosseo) == 1
					)
			       dx = posingle.lax + 2*scalax*(2*rand()-1.0) + 0.001*(posingle.ladestx-posingle.lax)	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			       dy = posingle.lay + 2*scalay*(2*rand()-1.0) + 0.001*(posingle.ladesty-posingle.lay)	#qui sarebbe meglio usare map()
				else
					dx = posingle.lax + scalax*(2*rand()-1.0) + 0.01*(posingle.ladestx-posingle.lax)	#qui sarebbe meglio usare map(); (10,10) è l'obiettivo da raggiungere
			        dy = posingle.lay + scalay*(2*rand()-1.0) + 0.01*(posingle.ladesty-posingle.lay)	#qui sarebbe meglio usare map()
			       
				end
	
       return Pedone(dx,dy,posingle.lavx,posingle.lavy,posingle.ladestx,posingle.ladesty)
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
			if (length(inrange(albero, a, raggio, true)) == 0 && esterno(a[1],a[2],edifici_coord)==0)
				posizioni[:,i] = a
			end
		end
	return posizioni
end
#########################################

# AGGORNAMENTO DEL VETTORE DELLE POSIZIONI
function aggiornamento_totale_nuovo(posizioni)
	albero = KDTree(posizioni)
		for i=1:2*N
			a = aggiornamento(posizioni[:,i])
			if (length(inrange(albero, a, raggio, true)) == 0 && esterno(a[1],a[2],edifici_coord)==0)
				posizioni[:,i] = a
			end
		end
	return posizioni
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
	posizioni_prima = copy(posizioni_dopo)
	aggiornamento_totale(posizioni_dopo)
	vel = veloc(posizioni_dopo,posizioni_prima)	
	for i =1:2*N
			mmm = norm(vel[:,i])/diag		
			set_position(circles[i], Vector2f(posizioni_dopo[:,i][1], posizioni_dopo[:,i][2]))
			ll=convert(Int64,round(255*norm(vel[:,i])) % 255)
		set_fillcolor(circles[i], colori(mmm))
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

