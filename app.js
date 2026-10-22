// =========================================================================
// HOI4 ASESOR - MOTOR JAVASCRIPT BLINDADO (SIN COMILLAS INVERTIDAS)
// =========================================================================
let apiKey = localStorage.getItem('hoi4_key') || '';
let historial = [];
let ultimaFirmaSync = '';
let analizandoAuto = false;

document.addEventListener('DOMContentLoaded', function () {
    if (apiKey) {
        var kInp = document.getElementById('inpKey');
        if (kInp) kInp.value = apiKey;
        setApi(true);
        var pSetup = document.getElementById('panelSetup');
        if (pSetup) pSetup.style.opacity = '0.6';
    }
});

function guardarKey() {
    var kInp = document.getElementById('inpKey');
    var k = kInp ? kInp.value.trim() : '';
    if (k.length < 20) {
        msg('sistema', '⚠️ Clave de API no válida. Consíguela en aistudio.google.com');
        return;
    }
    apiKey = k;
    localStorage.setItem('hoi4_key', k);
    setApi(true);
    var pSetup = document.getElementById('panelSetup');
    if (pSetup) pSetup.style.opacity = '0.6';
    msg('bien', '✅ Clave guardada correctamente.');
}

function setApi(ok) {
    var pto = document.getElementById('pto');
    if (pto) pto.className = 'punto ' + (ok ? 'ok' : 'error');
    var lbl = document.getElementById('apiLbl');
    if (lbl) lbl.textContent = ok ? 'Gabinete Conectado' : 'Sin Conexión';
}

function getVal(id, def) {
    if (def === undefined) def = '';
    var el = document.getElementById(id);
    return (el && el.value !== undefined && el.value !== null) ? el.value : def;
}

function datos() {
    return {
        pais: getVal('pais', 'Desconocido'),
        anio: getVal('anio', '1936'),
        ideologia: getVal('ideologia', 'Democrático'),
        objetivo: getVal('objetivo', 'Sobrevivir y vencer'),
        civ: getVal('fabCiv', '0'),
        mil: getVal('fabMil', '0'),
        doc: getVal('fabDoc', '0'),
        divs: getVal('divs', '0'),
        manpower: getVal('manpower', '0'),
        warSupport: getVal('warSupport', '---'),
        stability: getVal('stability', '---'),
        convoys: getVal('convoys', '---'),
        pp: getVal('pp', '---'),
        fuel: getVal('fuel', '---'),
        inWar: getVal('inWar', 'En Paz'),
        doctrina: getVal('doctrina', 'Sin doctrina')
    };
}

function prompt_sistema(d) {
    var tratamiento = 'Señor Presidente';
    var tonoIdeologico = 'Tratas al jugador con el debido respeto democrático, consultando al Parlamento y protegiendo el bienestar público.';

    var ideo = (d.ideologia || '').toLowerCase();
    if (ideo.indexOf('fascis') !== -1 || ideo.indexOf('nacion') !== -1) {
        tratamiento = 'Mi Conductor / Caudillo Supremo';
        tonoIdeologico = 'Hablas con fervor nacionalista, disciplina militar férrea y desprecio por la debilidad. El rearme de la patria y la autarquía son prioritarios.';
    } else if (ideo.indexOf('comun') !== -1 || ideo.indexOf('soviet') !== -1) {
        tratamiento = 'Camarada Secretario General';
        tonoIdeologico = 'Hablas en nombre del Comité Central y el proletariado. Priorizas el Plan Quinquenal, la industria pesada y la defensa contra el imperialismo burgués.';
    } else if (ideo.indexOf('no aline') !== -1 || ideo.indexOf('neutral') !== -1 || ideo.indexOf('monar') !== -1) {
        tratamiento = 'Su Majestad / Excelencia';
        tonoIdeologico = 'Hablas como el Canciller Imperial leal a la Corona, defendiendo la tradición, el honor y la soberanía del Reino.';
    }

    return 'Eres el "Gabinete Ministerial de Planificación y Guerra" en Hearts of Iron IV (HOI4).\n' +
        'Te diriges al jugador SIEMPRE como "' + tratamiento + '".\n' +
        'PERSONALIDAD OBLIGATORIA: ' + tonoIdeologico + '\n' +
        'Sé conciso, táctico y directo (máximo 3 párrafos).\n\n' +
        'ESTADO DE INTELIGENCIA NACIONAL EN VIVO:\n' +
        '- Nación: ' + d.pais + ' | Año: ' + d.anio + ' | Régimen: ' + d.ideologia + ' | Estado: ' + d.inWar + '\n' +
        '- Ejército: ' + d.divs + ' Divisiones desplegadas | Manpower disponible: ' + d.manpower + '\n' +
        '- Doctrina Militar Activa: ' + d.doctrina + ' (Diseña plantillas y tácticas adaptadas a esta doctrina)\n' +
        '- Combustible: ' + d.fuel + ' | Flota mercante: ' + d.convoys + ' Convoys\n' +
        '- Capacidad Industrial: ' + d.civ + ' Civiles | ' + d.mil + ' Militares | ' + d.doc + ' Astilleros\n' +
        '- Situación Interna: ' + d.stability + ' Estabilidad | ' + d.warSupport + ' Apoyo Bélico | ' + d.pp + ' Poder Político\n\n' +
        'INSTRUCCIÓN ESPECIAL OBLIGATORIA:\n' +
        'Al final de tu respuesta, añade SIEMPRE una sección destacada llamada:\n' +
        '\'📋 DIRECTIVA MINISTERIAL EN HOI4:\'\n' +
        'Dile exactamente qué orden ejecutiva o decisión del mod debe pulsar en la pestaña de Decisiones de HOI4 (por ejemplo: si debe mantener el Piloto Automático activado, o usar la Orden Ejecutiva de Fábricas Civiles, o pasar a Fábricas Militares, o comisionar refinerías).';
}

async function gemini(texto, sys) {
    if (!apiKey) throw new Error('Configura tu API Key arriba primero.');
    var url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=' + apiKey;

    var msgs = historial.slice(-10).map(function (h) {
        return { role: h.rol, parts: [{ text: h.txt }] };
    });
    msgs.push({ role: 'user', parts: [{ text: texto }] });

    var res;
    for (var intento = 1; intento <= 3; intento++) {
        res = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                system_instruction: { parts: [{ text: sys }] },
                contents: msgs,
                generationConfig: { temperature: 0.7, maxOutputTokens: 1000 }
            })
        });

        if (res.ok) break;

        var errJson = await res.json().catch(function () { return {}; });
        var errMsg = (errJson && errJson.error && errJson.error.message) ? errJson.error.message : '';

        if (res.status === 503 || errMsg.indexOf('high demand') !== -1 || errMsg.indexOf('spikes') !== -1) {
            if (intento < 3) {
                msg('sistema', '⏳ Servidores de Google con alta demanda. Reintentando intento ' + intento + '/3...');
                await new Promise(function (r) { setTimeout(r, 2000 * intento); });
                continue;
            }
        }

        if (res.status === 400 || res.status === 403) {
            setApi(false);
            throw new Error('API Key inválida o sin acceso. Revisa en aistudio.google.com');
        }
        throw new Error(errMsg || ('HTTP ' + res.status));
    }

    var data = await res.json();
    var text = (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts && data.candidates[0].content.parts[0]) ? data.candidates[0].content.parts[0].text : '';
    if (!text) throw new Error('No se recibió texto de respuesta.');
    return text;
}

async function autoAnalisisMinisterial(paisNombre, data) {
    if (analizandoAuto) return;
    analizandoAuto = true;
    cargando(true);
    var ind = indicador();
    try {
        var d = datos();
        if (data) {
            if (data.civs) d.civ = data.civs;
            if (data.mils) d.mil = data.mils;
            if (data.docks) d.doc = data.docks;
            if (data.divs) d.divs = data.divs;
            if (data.manpower) d.manpower = data.manpower;
            if (data.war_support) d.warSupport = data.war_support;
            if (data.stability) d.stability = data.stability;
            if (data.convoys) d.convoys = data.convoys;
            if (data.pp) d.pp = data.pp;
            if (data.fuel) d.fuel = data.fuel;
            if (data.in_war) d.inWar = data.in_war;
            if (data.doctrine) d.doctrina = data.doctrine;
            d.pais = paisNombre || data.tag || 'Francia';
            if (data.date) {
                var m = data.date.match(/\d{4}/);
                if (m) d.anio = m[0];
            }
        }

        var promptAuto = '¡Atención Gabinete! Se acaba de sincronizar la partida en vivo de Hearts of Iron IV.\n' +
            'Nación: ' + d.pais + ' (' + data.tag + ') | Fecha: ' + data.date + ' | Estado: ' + d.inWar + '.\n' +
            'Doctrina Militar Terrestre: ' + d.doctrina + '.\n' +
            'Capacidad: ' + d.civ + ' Fábricas Civiles | ' + d.mil + ' Fábricas Militares | ' + d.doc + ' Astilleros.\n' +
            'Fuerzas: ' + d.divs + ' Divisiones desplegadas | ' + d.manpower + ' Manpower | Combustible: ' + d.fuel + '.\n' +
            'Estabilidad: ' + d.stability + ' | Apoyo Bélico: ' + d.warSupport + ' | Poder Político: ' + d.pp + '.\n\n' +
            'Presenta tu informe ministerial de Estado:\n' +
            '1. Diagnóstico breve de nuestra economía (Fábricas Civiles vs Militares).\n' +
            '2. Estrategia inmediata (defensiva/ofensiva).\n' +
            '3. Objetivo prioritario (Guerra, Estabilidad o Producción).\n\n' +
            'IMPORTANTE: Genera directamente la lista de órdenes ejecutivas que debe activar el jugador en la pestaña Decisiones (Ej: "Activada Orden Ejecutiva: Fábricas Militares" o "Activada Orden Ejecutiva: Estabilidad")\n\n' +
            'Respuesta en formato:\n' +
            '📊 Informe del Gabinete\n' +
            'Diagnóstico:\n' +
            'Estrategia:\n' +
            'Objetivo:\n' +
            '📋 DIRECTIVA MINISTERIAL EN HOI4: [Nombre exacto de la decisión a pulsar]';

        try {
            var txt = await gemini(promptAuto, prompt_sistema(d));
            ind(1);
            analizarRespuestaMinisterial(txt, ind);
        } catch (e) {
            ind(0);
            console.error('Error auto-análisis:', e);
            msg('error', 'Error de conexión con IA.');
        }
    } finally {
        cargando(false);
        analizandoAuto = false;
    }
}