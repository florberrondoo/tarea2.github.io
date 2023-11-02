
function hash ( semilla, paso, N : Natural; p : Palabra ) : Natural;

var i:integer;
    codigo:Natural;

begin
    codigo:= semilla;

    for i:=1 to p.tope do
    begin
        codigo:= ((codigo * paso) + ord(p.cadena[i]))
    end;

    codigo:= codigo mod N;
    hash:= codigo;
end;
////////////////////////////////////////////////////////////////////////////////////ARREGLAR!!!!!!
function comparaPalabra ( p1, p2 : Palabra ) : Comparacion;

var i:integer;
    mm:boolean;
    compa:Comparacion;

begin
    i:=1;

    if(p1.tope <= p2.tope) then
    begin
        while (i <= p1.tope) and (p1.cadena[i] = p2.cadena[i]) do
            i:= i+1;

        if (i <= p1.tope) then
        begin
            mm:= (ord(p1.cadena[i]) < ord(p2.cadena[i]));
            if (mm) then
                compa:= menor
            else
                compa:= mayor;
        end

        else if (i > p1.tope) and (p1.tope = p2.tope) then
            compa:= igual;
    end

    else
    begin
        while (i <= p2.tope) and ((p2.cadena[i] = p1.cadena[i])) do
            i:= i+1;

        if (i <= p2.tope) then
        begin
            mm:= (ord(p1.cadena[i]) < ord(p2.cadena[i]));
            if (mm) then
                compa:= menor
            else
                compa:= mayor
        end;
    end;

    comparaPalabra:= compa;
end;
/////////////////////////////////////////////////////////////////////////////////////////////ARREGLAR!!!!!!
function mayorPalabraCant( pc1, pc2 : PalabraCant ) : boolean;
begin
	mayorPalabraCant:= ((pc1.cant = pc2.cant) or (pc1.cant > pc2.cant)) and (comparaPalabra(pc1.pal, pc2.pal) = mayor);
end;

procedure agregarOcurrencia ( p : Palabra; var pals : Ocurrencias );

var a,nuevo:Ocurrencias;

begin
	a:= pals;

	new(nuevo);
	nuevo^.palc.pal:= p;
	nuevo^.palc.cant:= 1;
	nuevo^.sig:= nil;
	
	while (a <> nil) and (comparaPalabra(p,a^.palc.pal) <> igual) do
		a:= a^.sig;
	
	if (a = nil) then
	begin
		a:= pals;
		
		while (a^.sig <> nil) do
			a:= a^.sig;
		
		a^.sig:= nuevo;
	end
	
	else
	begin
		a^.palc.cant:= a^.palc.cant + 1;
	end;
end;

procedure inicializarPredictor ( var pred: Predictor );

var a:Ocurrencias;
	i:Natural;
	
begin
	for i:=1 to MAXHASH do
     while (pred[i] <> nil) do
     begin
        a:= pred[i];
        pred[i]:= pred[i]^.sig;
        dispose(a)
     end;
end;

procedure entrenarPredictor ( txt : Texto; var pred: Predictor );

var aux2,a:Ocurrencias;
    predAux:Predictor;
    txtAux:Texto;

begin
   predAux:= pred;
   txtAux:= txt;

   while (predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)] <> nil) and (txtAux^.sig <> nil) do
   begin

      while (predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)] <> nil) and (comparaPalabra(predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]^.palc.pal, txtAux^.sig^.info) <> igual) do
         predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]:= predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]^.sig;

      if (predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)] = nil) then
      begin
         new(a);
         a^.palc.pal:= txtAux^.sig^.info;
         a^.palc.cant:= 1;
         aux2:= predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)];
         a^.sig:= aux2;
         predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]:= a;
      end

      else if (comparaPalabra(predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]^.palc.pal, txtAux^.sig^.info) = igual) then
      begin
         predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]^.palc.cant:= predAux[hash(SEMILLA,PASO,MAXHASH,txtAux^.info)]^.palc.cant + 1
      end;

      txtAux:= txtAux^.sig;
   end;
end;

procedure insOrdAlternativas ( pc : PalabraCant; var alts: Alternativas );

var aux:Alternativas;
    i:integer;

begin
   if (mayorPalabraCant(pc, alts.pals[alts.tope])) then
   begin
      aux:=alts;
      aux.pals[alts.tope].pal:= pc.pal;
      aux.pals[alts.tope].cant:= pc.cant;

      i:=1;
      while ((aux.tope - i) >= 1) and (mayorPalabraCant(pc, aux.pals[(alts.tope - i)])) do
      begin
         aux.pals[alts.tope].pal:= aux.pals[(alts.tope - i)].pal;
         aux.pals[alts.tope].cant:= aux.pals[(alts.tope - i)].cant;
         aux.pals[(alts.tope - i)].pal:= pc.pal;
         aux.pals[(alts.tope - i)].cant:= pc.cant;
         i:= i+1
      end;

      alts:= aux
   end;
end;

procedure obtenerAlternativas ( p : Palabra; pred : Predictor; var alts: Alternativas );
begin
	
end;
