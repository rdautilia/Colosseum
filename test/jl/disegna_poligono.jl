
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

