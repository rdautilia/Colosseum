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
"n18" => [447 171]
)

const origini = [cn["n1"]]
#const destinazioni = [[400 400]]
#cn["n"] => [cn["n"],cn["n"],cn["n"],cn["n"],cn["n"]]

const ledestinazioni = Dict{Array, Array}(
cn["n1"] => [cn["n2"],cn["n15"]],
cn["n2"] => [cn["n3"], cn["n5"], cn["n14"], cn["n15"], cn["n16"]],
cn["n3"] => [cn["n2"], cn["n4"], cn["n5"],cn["n14"],cn["n18"]],
cn["n4"] => [cn["n7"]],
cn["n5"] => [cn["n6"],cn["n8"],cn["n9"],cn["n10"]],
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
cn["n18"] => [cn["n3"],cn["n14"]]

)

##crea il render text
function creanodo(n::String,coord::Array)
	nodo = RenderText()
	set_position(nodo, Vector2f(coord[1], coord[2]))
	set_string(nodo, n)
	set_color(nodo, SFML.Color(153,51,255))
	set_charactersize(nodo, 18)
	return nodo
end
####################
