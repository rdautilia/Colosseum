const cn = Dict{String, Array}(
"n0" => [430 492],
"n1" => [287 202],
"n2" => [329 294],
"n3" => [273 312],
"n4" => [188 330],
"n5" => [165 248],
"n6" => [3 140],
"n7" => [169 191],
"n8" => [99 8],
"n9" => [94 491],
"n10" => [732 653],
"n11" => [168 428],
"n12" => [516 283],
"n13" => [735 383],
"n14" => [740 361],
"n15" => [530 229],
"n16" => [624 3],
"c1" => [336 312],
"c2" => [242 375],
"c3" => [211 473],
"c4" => [231 556],
"c5" => [295 629],
"c6" => [364 668],
"c7" => [460 683],
"c8" => [549 663],
"c9" => [620 599],
"c10" => [652 502],
"c11" => [601 380],
"c12" => [498 313],
"c13" => [371 306],
"i1" => [252 547],
"i2" => [374 648],
"i3" => [539 644],
"u" => [488 327],
"o1" => [76 847],
"o2" => [4 456],
"o3" => [994 716],
"o4" => [996 606],
"o5" => [427 4],
"g1" => [70 600],
"g2" => [100 605],
"g3" => [131 613],
"g4" => [176 622],
"cs1" => [202 662],
"cs2" => [431 721],
"lm" => [783 513],
"da" => [961 378]
)

const origini = [cn["n1"], cn["n6"],cn["n8"], cn["o1"],cn["o2"],cn["o3"],cn["o4"],cn["o5"],cn["n16"],cn["da"]]
#const destinazioni = [[400 400]]
#cn["n"] => [cn["n"],cn["n"],cn["n"],cn["n"],cn["n"]]

const ledestinazioni = Dict{Array, Array}(
cn["n1"] => [cn["n2"],cn["n3"],cn["n4"],cn["n5"],cn["n7"]],
cn["n2"] => [cn["n1"],cn["n3"],cn["n4"],cn["n5"],cn["c1"],cn["c2"],cn["c2"],cn["c2"],cn["c12"],cn["c13"]],
cn["n3"] => [cn["n1"],cn["n2"],cn["n4"],cn["n5"],cn["c1"],cn["c2"],cn["c13"]],
cn["n4"] => [cn["n2"],cn["n3"],cn["n4"],cn["n5"],cn["c1"],cn["c2"],cn["c3"],cn["c4"]],
cn["n5"] => [cn["n1"],cn["n2"],cn["n3"],cn["n4"],cn["n6"]],
cn["n6"] => [cn["n2"],cn["n3"],cn["n4"]],
cn["n7"] => [cn["n1"],cn["n8"]],
cn["n8"] => [cn["n7"]],
cn["n9"] => [cn["n4"],cn["n11"]],
cn["n10"] => [cn["c9"],cn["o3"]],
cn["n11"] => [cn["c4"]],
cn["n12"] => [cn["n1"],cn["n13"],cn["n2"],cn["c11"],cn["c12"],cn["c13"]],
cn["n13"] => [cn["n12"],cn["n14"]],
cn["n14"] => [cn["n13"],cn["n13"],cn["n13"],cn["n15"],cn["da"]],
cn["n15"] => [cn["n14"],cn["n16"]],
cn["n16"] => [cn["n15"]],
cn["c1"] => [cn["c2"]],
cn["c2"] => [cn["c3"],cn["c1"]],
cn["c3"] => [cn["c2"],cn["c4"]],
cn["c4"] => [cn["c3"],cn["c5"],cn["c6"],cn["i1"],cn["i1"],cn["i1"],cn["i1"],cn["i1"]],
cn["c5"] => [cn["c3"],cn["c4"],cn["c6"],cn["c7"]],
cn["c6"] => [cn["c4"],cn["c5"],cn["c7"],cn["c8"],cn["i1"],cn["i2"],cn["i2"],cn["i2"],cn["i2"]],
cn["c7"] => [cn["c5"],cn["c6"],cn["c8"],cn["c9"]],
cn["c8"] => [cn["c6"],cn["c7"],cn["c9"],cn["c10"],cn["i3"],cn["i3"],cn["i3"],cn["i3"],cn["i3"]],
cn["c9"] => [cn["c7"],cn["c8"],cn["c10"]],
cn["c10"] => [cn["c9"],cn["c11"],cn["lm"]],
cn["c11"] => [cn["c10"],cn["c12"]],
cn["c12"] => [cn["c11"],cn["c13"]],
cn["c13"] => [cn["c12"]],
cn["i1"] => [cn["n0"]],
cn["i2"] => [cn["n0"]],
cn["i3"] => [cn["n0"]],
cn["n0"] => [cn["u"]],
cn["o1"] => [cn["g1"],cn["g2"],cn["g3"],cn["g4"]],
cn["o2"] => [cn["n9"]],
cn["o3"] => [cn["n10"]],
cn["o4"] => [cn["lm"]],
cn["o5"] => [cn["n7"]],
cn["g1"] => [cn["n9"]],
cn["g2"] => [cn["n9"]],
cn["g3"] => [cn["c4"]],
cn["g4"] => [cn["c4"],cn["c6"],cn["cs1"]],
cn["cs1"] => [cn["cs2"]],
cn["cs2"] => [cn["c6"],cn["c8"]],
cn["u"] => [cn["n12"],cn["c12"]],
cn["lm"] => [cn["o4"],cn["c10"]],
cn["da"] => [cn["n14"]]
)

##crea il render text
function creanodo(n::String,coord::Array)
	nodo = RenderText()
	set_position(nodo, Vector2f(coord[1], coord[2]))
	set_string(nodo, n)
	set_color(nodo, SFML.Color(153,51,255))
	set_charactersize(nodo, 12)
	return nodo
end
####################
function disegna_link(finestra)
	p1=Vector2f(0.0,0.0)
	p2=Vector2f(0.0,0.0)
	for k in keys(ledestinazioni)
		p1 = Vector2f(k[1], k[2])
		for l in ledestinazioni[k]
			p2 = Vector2f(l[1],l[2])
			line = Line(p1, p2, 1)
			set_fillcolor(line, SFML.Color(160,160,160))
			draw(finestra, line)
		end
	end
end










