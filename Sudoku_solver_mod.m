% TRABAJO

% Desarrollar un sistema de visión que resuelva Sudokus. Utilice una webcam
% o la cámara de un teléfono móvil (ver ejercicio 9). Se puede suponer que 
% frente a la cámara estará un (único) Sudoku estándar de 9x9 números (aquí
% verá muchos). Tras resolverlo se deberá mostrar en pantalla sobre la 
% imagen, en las posiciones vacías, los números faltantes.

% Autores: Ricardo Camacho, Pedro Estévez, Alberto García

clear, clc, close all;

% Cargamos la imagen del sudoku
sudoku = imread('hardest_sudoku.jpg');

% Creamos una copia a escala de grises
Grayscale = rgb2gray(sudoku);

% Y otra en blanco y negro
BW = imbinarize(Grayscale,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);

% Creamos otra imagen binaria complementada sin los números, de forma que
% nos quedamos con sólo el fondo del sudoku y las líneas están a 1
BW2 = bwareafilt(imcomplement(BW),1,'largest');

% Identificamos todas las coordenadas de esas líneas
[fila,columna] = find(BW2==1);

% Y como ya tenemos las líneas, podemos quedarnos con todo lo de dentro, es
% decir, cortamos la imagen para quedarnos sólo con el sudoku

% Primero nos quedamos con la imagen original recortada
BW3 = BW(min(fila):max(fila),min(columna):max(columna));

% Luego con la imagen complementada recortada
BW4 = BW2(min(fila):max(fila),min(columna):max(columna));

% Y finalmente restamos las dos para que nos queden exclusivamente los
% números en blanco sobre un fondo negro
BW5 = logical(imcomplement(BW3)-BW4);

% Calculamos los centroides  de cada casilla del sudoku
s = regionprops(imcomplement(BW4),'centroid');
centroids = cat(1, s.Centroid);

% Mostramos la imagen inicial con los centroides
imshow(BW3)
hold on
plot(centroids(:,1),centroids(:,2),'b*')
hold off

% Calculamos ahora los píxeles de las casillas, porque éstos dependerán de
% la resolución de la imagen
[ancho,alto] = size(BW5);     
ancho_casilla = floor(ancho/9);      
alto_casilla = floor(alto/9);   

% Inicializamos nuestra matriz
sudokuMatrix = [];              

% Procedemos a identificar los números. Los offsets avanzan la posición al
% inicio de la casilla que queremos escanear, y los bucles indican el final
offset_filas = 1; 
for f = 1:9
    offset_columnas = 1; 
    for c = 1:9
        BW6 = BW5(offset_filas:f*alto_casilla,offset_columnas:c*ancho_casilla);
        offset_columnas = c*ancho_casilla;   % Avanzamos el offset de las columnas
        
        % OCR reconoce el texto de cada casilla
        identificacion = ocr(BW6, 'CharacterSet', '0123456789', 'TextLayout','Block');
        numero = str2num(identificacion.Text);
        
        % Y le asignamos un número a esa posición
        % El switch no puede operar con un congunto vacío, así que tenemos
        % que poner un if para comprobar si es un cero
        if (isempty(numero) == 1) 
            sudokuMatrix(f,c) = 0;
        else
            switch numero 
                case 1
                    sudokuMatrix(f,c) = 1; 
                case 2
                    sudokuMatrix(f,c) = 2;
                case 3
                    sudokuMatrix(f,c) = 3;
                case 4
                    sudokuMatrix(f,c) = 4;
                case 5
                    sudokuMatrix(f,c) = 5;
                case 6
                    sudokuMatrix(f,c) = 6;
                case 7
                    sudokuMatrix(f,c) = 7;
                case 8
                    sudokuMatrix(f,c) = 8;
                case 9 
                    sudokuMatrix(f,c) = 9;
            end
        end
    end
    offset_filas = f*alto_casilla;    % Avanzamos el offset de las filas
end

% Ya tenemos totalmente identificada nuestra matriz. Ahora tenemos que
% ponerla de forma que la función sudokuEngine, que será la que resuelva el
% sudoku, pueda operar con ella. Para ello tenemos que transformarla a
% tantas filas como números haya, y las dos primeras columnas son las
% coordenadas y la tercerla el valor de esa posición
clc; 
c = [];
for i=1:9
    for j=1:9
        if (sudokuMatrix(i,j)>0)
            b = [i,j,sudokuMatrix(i,j)];
            c = [b;c];
        end
    end
end
 
% Una vez identificados los números procedemos a dibujar el sudoku original
drawSudoku(c);

% Resolvemos el sudoku usando la toolbox de matlab
type sudokuEngine;
S = sudokuEngine(c);

% Y mostramos el resultado final
drawSudoku(S);
clc;
