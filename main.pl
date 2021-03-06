:- [diets].
:- ['GLC'].

% Definición de reglas para los parámetros
tipo(X):- posibles_tipos(L), askTipo(X,L).
calorias(X):- askCalorias(X, 1200, 4200).
padecimientos(X):- posibles_padecimientos(L), askPadecimientos(X,L).
actividad(X):- askActividad(X).
comida(X):- posibles_comidas(L),askComida(X,L).

% main
main:- startup1.

startup1:-
   my_read(ListResponse),
   oracion(ListResponse,[]),
   ListResponse = ['Hola','NutriTec'],
   write('Hola, encantado de verlo mejorar su estilo de vida. Cuénteme ¿en qué lo puedo ayudar?'),
   nl,
   startup2.

startup1:-startup1.

startup2:-
   my_read(ListResponse),
   oracion(ListResponse,[]),
   write('Excelente iniciativa. Estamos para asesorarte en todo lo que necesites.'),
   nl,
   identify.
startup2:-
   write('No te entendí, ¿Puedes volverlo a formular?'),
   nl,
   startup2.

identify:-
  retractall(known(_,_)),         % clear stored information
  dieta(X),
  write(X),nl.
identify:-
  write('Sus selecciones no calzan con ninguna dieta.'),nl.

% Preguntar el tipo de dieta que prefiere
askTipo(X,_):-  % Si ya se conoce entonces solo se toma la conocida
  known(tipo,X), !.

askTipo(X,Menu):-  % Si no se conoce entonces se pregunta y se guarda como "known"
  write('¿Tiene alguna preferencia para el tipo de dieta a realizar entre las siguientes opciones?'),
  nl, display_menu(Menu),
  my_read(ListResponse),
  askTipoAux(X,ListResponse,Menu).

askTipo(X,Menu):- askTipo(X,Menu).

askTipoAux(X,ListResponse,Menu):-
  oracion(ListResponse,[]),
  miembro(X,ListResponse),
  miembro(X,Menu),
  !,
  asserta(known(tipo,X)).

askTipoAux(X,ListResponse,_Menu):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  (Atom='No', X=[] ; Atom='proteica', X=proteina),
  !,
  asserta(known(tipo,X)).

askTipoAux(_X,_ListResponse,_Menu):-
  write('No comprendí lo que indicaste, ¿Puedes volverlo a formular?'),
  !,
  fail.

% Preguntar calorías
askCalorias(X, _Min, _Max):-
  known(calorias,X),
  !.
  
askCalorias(X, _Min, _Max):-
  write('¿Tienes pensado/a una cantidad específica de calorías diarias por consumir?'),
  nl,
  my_read(ListResponse),
  askCaloriasAux(X,ListResponse).

askCalorias(X, Min, Max):- askCalorias(X, Min, Max).

askCaloriasAux(X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  atom_number(Atom,X),
  1199<X,
  X<4201,
  !,
  asserta(known(calorias,X)).

askCaloriasAux(X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  Atom='No',
  X=[],
  !,
  asserta(known(calorias,X)).
  
askCaloriasAux(_X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  atom_number(Atom,Y),
  Y<1200,
  write('La cantidad de calorías que indicaste está por debajo del mínimo recomendado, vuelve a indicar un nuevo valor.'),
  !,
  fail.
  
askCaloriasAux(_X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  atom_number(Atom,Y),
  Y>4200,
  write('La cantidad de calorías que indicaste está por encima del máximo recomendado, vuelve a indicar un nuevo valor.'),
  !,
  fail.

askCaloriasAux(_X,_ListResponse):-
  write('No compredí lo que indicaste, ¿Puedes volverlo a formular?'),
  !,
  fail.

% Preguntar padecimientos

askPadecimientos(X,_):-  % Si ya se conoce entonces solo se toma la conocida
  known(padecimientos,X), !.

askPadecimientos(X,Menu):-  % Si no se conoce entonces se pregunta y se guarda como "known"
  write('Tiene alguna enfermedad que pueda afectar su dieta, como las siguientes opciones?'),
  nl, display_menu(Menu),
  my_read(ListResponse),
  askPadecimientosAux(X,ListResponse,Menu).

askPadecimientos(X,Menu):- askPadecimientos(X,Menu).

askPadecimientosAux(X,ListResponse,ListPadecimientos):-
  oracion(ListResponse,[]),
  miembro(X,ListResponse),
  miembro(X,ListPadecimientos),
  !,
  asserta(known(padecimientos,X)).

askPadecimientosAux(X,ListResponse,_ListPadecimientos):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  Atom='No',
  X=[],
  !,
  asserta(known(padecimientos,X)).

askPadecimientosAux(_X,_ListResponse,_ListPadecimientos):-
  write('No compredí lo que indicaste, ¿Puedes volverlo a formular?'),
  !,
  fail.

% Preguntar nivel de actividad
askActividad(X):-
  known(actividad, X), !.
  
askActividad(X):-
  write('Cuántas veces a la semana es activo/a físicamente?'),
  nl,
  my_read(ListResponse),
  askActividadAux(X,ListResponse).

askActividad(X):- askActividad(X).

askActividadAux(X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  atom_number(Atom,X),
  X=<7,
  !,
  asserta(known(actividad,X)).

askActividadAux(X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  atom_number(Atom,X),
  X>7,
  !,
  write('No se tienen dietas disponibles para una cantidad tan alta de actividad física, indique una cantidad menor'),
  !,
  fail.

askActividadAux(X,ListResponse):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  Atom='No',
  X=0,
  !,
  asserta(known(actividad,X)).

askActividadAux(_X,_ListResponse):-
  write('No compredí lo que indicaste, ¿Puedes volverlo a formular?'),
  !,
  fail.

% Preguntar comida no deseada
askComida(X,_Comidas):-
  known(comida, X),!.
  
askComida(X,Comidas):-
  write('¿Hay alguna comida en específico que no desee comer?'),
  nl,
  my_read(ListResponse),
  askComidaAux(X,ListResponse,Comidas).

askComida(X,Comidas):-askComida(X,Comidas).

askComidaAux(X,ListResponse,Comidas):-
  oracion(ListResponse,[]),
  miembro(X,ListResponse),
  miembro(X,Comidas),
  !,
  asserta(known(comida,X)).

askComidaAux(X,ListResponse,_Comidas):-
  oracion(ListResponse,[]),
  miembro(Atom,ListResponse),
  Atom='No',
  X=[],
  !,
  asserta(known(comida,X)).

askComidaAux(_X,_ListResponse,_Comidas):-
  write('No compredí lo que indicaste, ¿Puedes volverlo a formular?'),
  !,
  fail.

% Funciones auxiliares para mostrar menú de opciones (como para mostrar tipos de padecimientos)
display_menu(Menu):-
  disp_menu(Menu), !. % No backtrackear cuando se termina

disp_menu([]). % Fin de recursión
disp_menu([[] | Rest]):- % Saltarse el elemento vacío []
  disp_menu(Rest).

disp_menu([Item | Rest]):- % Recursivamente escribir la lista
  write('- '),write(Item),nl, 
  disp_menu(Rest).
