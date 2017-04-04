const cn = Dict{String, Array}(
"n1" => [276 67],
"n2" => [355 107],
"n3" => [352 189],
"n4" => [480 382],
"n5" => [320 194],
"n6" => [291 247],
"n7" => [420 535],
"n8" => [233 206],
"n9" => [179 226],
"n10" => [198 273],
"n11" => [242 316],
"n12" => [255 403],
"n13" => [318 509],
"n14" => [650 217],
"n15" => [13 17],
"n16" => [530 179],
"n17" => [894 310],
"n18" => [447 171],
"n19" => [5 349],
"n20" => [116 395],
"n21" => [88 449],
"n22" => [218 479],
"n23" => [199 529],
"n24" => [129 553],
"n25" => [85 510],
"n26" => [132 561],
"n27" => [63 753],
"n28" => [45 843]
)

const origini = [cn["n1"], cn["n15"], cn["n19"], cn["n28"]]
#const destinazioni = [[400 400]]
#cn["n"] => [cn["n"],cn["n"],cn["n"],cn["n"],cn["n"]]

const ledestinazioni = Dict{Array, Array}(
cn["n1"] => [cn["n2"],cn["n2"],cn["n15"]],
cn["n2"] => [cn["n3"], cn["n5"], cn["n6"], cn["n14"], cn["n15"], cn["n16"]],
cn["n3"] => [cn["n2"], cn["n4"], cn["n4"], cn["n4"], cn["n4"], cn["n5"],cn["n14"],cn["n18"]],
cn["n4"] => [cn["n7"]],
cn["n5"] => [ cn["n3"], cn["n3"],cn["n6"],cn["n8"],cn["n9"],cn["n10"]],
cn["n6"] => [cn["n5"], cn["n4"]],
cn["n7"] => [cn["n12"],cn["n13"]],
cn["n8"] => [cn["n5"],cn["n6"],cn["n9"],cn["n10"]],
cn["n9"] => [cn["n5"],cn["n6"],cn["n8"],cn["n10"]],
cn["n10"] => [cn["n3"],cn["n5"],cn["n6"],cn["n8"],cn["n9"],cn["n11"],cn["n12"],cn["n13"]],
cn["n11"] => [cn["n6"],cn["n8"],cn["n9"],cn["n10"]],
cn["n12"] => [cn["n7"],cn["n10"],cn["n11"],cn["n13"]],
cn["n13"] => [cn["n7"],cn["n9"],cn["n10"],cn["n11"],cn["n12"]],
cn["n14"] => [cn["n16"],cn["n17"]],
cn["n15"] => [cn["n1"],cn["n2"]],
cn["n16"] => [cn["n3"],cn["n14"]],
cn["n17"] => [cn["n14"]],
cn["n18"] => [cn["n3"],cn["n14"]],
cn["n19"] => [cn["n20"]],
cn["n20"] => [cn["n9"],cn["n19"], cn["n21"]],
cn["n21"] => [cn["n20"], cn["n22"]],
cn["n22"] => [cn["n11"],cn["n12"],cn["n13"],cn["n21"]],
cn["n23"] => [cn["n13"],cn["n22"],cn["n24"],cn["n25"],cn["n26"]],
cn["n24"] => [cn["n23"],cn["n25"],cn["n26"],cn["n27"]],
cn["n25"] => [cn["n21"],cn["n23"],cn["n24"],cn["n26"],cn["n27"]],
cn["n26"] => [cn["n23"],cn["n24"],cn["n25"],cn["n27"],cn["n28"]],
cn["n27"] => [cn["n23"],cn["n24"],cn["n25"],cn["n26"],cn["n28"]],
cn["n28"] => [cn["n24"],cn["n25"],cn["n26"],cn["n27"]],



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










