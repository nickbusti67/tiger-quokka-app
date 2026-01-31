import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'supabase_service.dart';

class RitualService extends ChangeNotifier {
  final SupabaseService _supabaseService;
  
  RitualService(this._supabaseService) {
    _initSupabase();
  }

  final math.Random _random = math.Random();
  StreamSubscription? _roomSubscription;
  
  /// Inizializza Supabase e le subscription
  Future<void> _initSupabase() async {
    if (!_supabaseService.isInitialized) {
      await _supabaseService.initialize();
    }
  }

  // Mock questions database - domande normali
  final List<RitualQuestion> _questions = const [
    RitualQuestion(
      id: 'q1',
      text: 'Se potessi rivivere un momento insieme, quale sceglieresti?',
      category: QuestionCategory.heart,
    ),
    RitualQuestion(
      id: 'q2',
      text: 'Qual è la cosa che ti fa sentire più amato/a da me?',
      category: QuestionCategory.heart,
    ),
    RitualQuestion(
      id: 'q3',
      text: 'Dove vedi il nostro amore tra dieci anni?',
      category: QuestionCategory.destiny,
    ),
    RitualQuestion(
      id: 'q4',
      text: 'Qual è il ricordo più prezioso del nostro primo incontro?',
      category: QuestionCategory.heart,
    ),
    RitualQuestion(
      id: 'q5',
      text: 'Se potessimo teletrasportarci ora, dove andresti con me?',
      category: QuestionCategory.destiny,
    ),
    RitualQuestion(
      id: 'q6',
      text: 'Cosa ti ha fatto innamorare di me all\'inizio?',
      category: QuestionCategory.heart,
    ),
    RitualQuestion(
      id: 'q7',
      text: 'Qual è il nostro super potere come coppia?',
      category: QuestionCategory.destiny,
    ),
    RitualQuestion(
      id: 'q8',
      text: 'Cosa vorresti che facessimo insieme che non abbiamo mai fatto?',
      category: QuestionCategory.mind,
    ),
  ];

  // Domande HOT molto spinte per modalità intimacy (100+ domande)
  final List<RitualQuestion> _spicyQuestions = const [
    // Fantasie e Desideri (1-25)
    RitualQuestion(
      id: 'hot1',
      text: 'Qual è la tua fantasia sessuale più segreta che non mi hai mai confessato?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot2',
      text: 'Cosa vorresti che facessi a letto che non ho ancora provato con te?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot3',
      text: 'Descrivi in dettaglio il momento più eccitante che abbiamo vissuto insieme.',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot4',
      text: 'Quale parte del mio corpo ti eccita di più e cosa vorresti farci?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot5',
      text: 'Se potessi scegliere un luogo "proibito" per fare l\'amore, quale sarebbe?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot6',
      text: 'Cosa ti piacerebbe sperimentare sessualmente che non abbiamo mai fatto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot7',
      text: 'Qual è il tuo ricordo più hot di un nostro momento intimo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot8',
      text: 'C\'è qualcosa di me che ti eccita particolarmente quando facciamo l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot9',
      text: 'Descrivi la tua posizione preferita e perché ti piace così tanto.',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot10',
      text: 'Qual è il tuo maggiore desiderio sessuale per questa settimana?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot11',
      text: 'Cosa pensi quando ti guardo in un certo modo? Ti eccita?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot12',
      text: 'Raccontami un sogno erotico che hai fatto su di noi.',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot13',
      text: 'C\'è una parte del mio corpo che vorresti esplorare di più?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot14',
      text: 'Qual è il tuo turn-on più forte quando siamo soli?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot15',
      text: 'Se potessi svegliarmi domani e fare qualsiasi cosa con te, cosa sceglieresti?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot16',
      text: 'Qual è la cosa più perversa a cui hai pensato mentre eravamo in pubblico insieme?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot17',
      text: 'Ti piacerebbe provare a dominare o essere dominato/a? Come?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot18',
      text: 'Qual è il tuo punto più sensibile che vorresti che tocassi più spesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot19',
      text: 'Descrivi in dettaglio cosa vorresti che ti facessi stasera.',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot20',
      text: 'Qual è la fantasia che ti imbarazza di più confessare?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot21',
      text: 'Ti ecciterebbe fare l\'amore in un posto dove potremmo essere scoperti?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot22',
      text: 'Qual è il tuo gioco erotico preferito che vorresti fare con me?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot23',
      text: 'C\'è un film o una scena che ti ha eccitato e vorresti ricreare?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot24',
      text: 'Cosa ti piacerebbe che ti sussurrassi all\'orecchio durante il sesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot25',
      text: 'Qual è la parte del preliminare che ti fa impazzire di più?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    
    // Esperienze e Ricordi (26-50)
    RitualQuestion(
      id: 'hot26',
      text: 'Qual è stato il nostro momento più selvaggio a letto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot27',
      text: 'Raccontami nei dettagli la prima volta che abbiamo fatto l\'amore.',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot28',
      text: 'Qual è stata la volta più intensa e perché?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot29',
      text: 'Ti sei mai toccato/a pensando a me? Quando è successo l\'ultima volta?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot30',
      text: 'Qual è il complimento più hot che vorresti ricevere da me dopo il sesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot31',
      text: 'C\'è stato un momento in cui hai desiderato saltarmi addosso immediatamente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot32',
      text: 'Qual è la cosa più audace che abbiamo fatto insieme sessualmente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot33',
      text: 'Ti ricordi di una volta in cui non riuscivamo a toglierci le mani di dosso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot34',
      text: 'Qual è stato il nostro momento più lungo e appassionato?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot35',
      text: 'Hai mai avuto un orgasmo così intenso con me che ti ha sorpreso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot36',
      text: 'Qual è il momento in cui mi hai trovato più irresistibile sessualmente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot37',
      text: 'C\'è una situazione specifica che ti eccita solo a ripensarci?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot38',
      text: 'Qual è la cosa più spontanea che abbiamo fatto sessualmente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot39',
      text: 'Ti è mai capitato di eccitarti solo guardandomi fare qualcosa?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot40',
      text: 'Qual è il bacio più passionale che ci siamo dati?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot41',
      text: 'Ricordi una volta in cui abbiamo rischiato di essere scoperti?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot42',
      text: 'Qual è stata la sorpresa più hot che mi hai fatto o che ti ho fatto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot43',
      text: 'C\'è un vestito o un look che mi hai visto indossare che ti ha fatto impazzire?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot44',
      text: 'Qual è il messaggio più sexy che mi hai mandato o vorresti mandarmi?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot45',
      text: 'Ti è mai capitato di non riuscire a smettere di pensare a noi mentre facevamo l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot46',
      text: 'Qual è il momento in cui hai sentito più connessione fisica con me?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot47',
      text: 'C\'è stata una volta in cui il sesso è stato così buono che non volevi che finisse?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot48',
      text: 'Qual è la cosa più dolce e sexy che ti ho fatto contemporaneamente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot49',
      text: 'Ti ricordi di un momento in cui ci siamo guardati negli occhi durante il sesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot50',
      text: 'Qual è stato il momento più romantico e passionale insieme?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    
    // Preferenze e Stili (51-75)
    RitualQuestion(
      id: 'hot51',
      text: 'Preferisci il sesso dolce e romantico o selvaggio e passionale?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot52',
      text: 'Ti piace di più dare o ricevere piacere?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot53',
      text: 'Qual è il tuo ritmo preferito: lento e sensuale o veloce e intenso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot54',
      text: 'Preferisci che sia io a prendere l\'iniziativa o ti piace essere tu?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot55',
      text: 'Ti eccita di più il contatto visivo o preferisci chiudere gli occhi?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot56',
      text: 'Preferisci le luci accese o spente quando facciamo l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot57',
      text: 'Ti piacciono più i preliminari lunghi o preferisci arrivare subito al punto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot58',
      text: 'Qual è il tuo momento preferito della giornata per fare l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot59',
      text: 'Ti piace di più il sesso pianificato o spontaneo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot60',
      text: 'Preferisci sessioni veloci e intense o lunghe e rilassate?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot61',
      text: 'Ti eccita di più quando sono dolce o quando sono più aggressivo/a?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot62',
      text: 'Preferisci che ti baci dolcemente o in modo più passionale durante il sesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot63',
      text: 'Ti piace di più quando controllo tutto o quando mi lasci fare?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot64',
      text: 'Qual è il suono o gemito che ti eccita di più durante il sesso?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot65',
      text: 'Ti piace di più quando parliamo durante o quando restiamo in silenzio?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot66',
      text: 'Preferisci che ti tocchi delicatamente o con più intensità?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot67',
      text: 'Ti eccita di più quando ti guardo o quando ti sussurro cose all\'orecchio?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot68',
      text: 'Preferisci una sessione unica lunga o più momenti brevi nella stessa giornata?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot69',
      text: 'Ti piace di più quando ti lodo o quando sono più provocante?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot70',
      text: 'Qual è il tipo di carezza che ti fa perdere il controllo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot71',
      text: 'Preferisci che inizi dal collo o da altre parti del corpo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot72',
      text: 'Ti eccita di più l\'anticipazione o la sorpresa?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot73',
      text: 'Preferisci che sia diretto/a o che ti faccia desiderare di più?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot74',
      text: 'Ti piace di più quando sono vestito/a o semi-vestito/a all\'inizio?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot75',
      text: 'Qual è il tipo di abbraccio dopo il sesso che ti fa sentire più completo/a?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    
    // Scenari e Ruoli (76-100)
    RitualQuestion(
      id: 'hot76',
      text: 'Ti piacerebbe provare un gioco di ruolo? Quale personaggio vorresti interpretare?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot77',
      text: 'Se potessi interpretare chiunque per una notte, chi saresti e cosa faresti?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot78',
      text: 'Ti ecciterebbe uno scenario dove uno di noi due ha il controllo totale?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot79',
      text: 'Qual è lo scenario più tabù che ti eccita segretamente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot80',
      text: 'Ti piacerebbe provare a fare l\'amore in macchina in un posto isolato?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot81',
      text: 'Qual è il tuo scenario fantasy preferito che coinvolge noi due?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot82',
      text: 'Ti ecciterebbe fare l\'amore sotto la doccia o nella vasca?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot83',
      text: 'Qual è il posto più insolito in casa dove vorresti farlo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot84',
      text: 'Ti piacerebbe provare qualcosa di nuovo in camera da letto? Tipo cosa?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot85',
      text: 'Qual è il tuo scenario ideale per una serata perfetta che finisce a letto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot86',
      text: 'Ti ecciterebbe se usassimo specchi per guardarci mentre facciamo l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot87',
      text: 'Qual è il costume o l\'outfit più sexy che vorresti vedermi indossare?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot88',
      text: 'Ti piacerebbe provare a bendare uno di noi due? Chi?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot89',
      text: 'Qual è il tuo scenario di seduzione perfetto che vorresti vivere?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot90',
      text: 'Ti ecciterebbe fare l\'amore in un hotel di lusso o in una location esotica?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot91',
      text: 'Qual è il gioco erotico più audace che vorresti provare con me?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot92',
      text: 'Ti piacerebbe che ti sorprendessi con qualcosa di nuovo? Tipo cosa?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot93',
      text: 'Qual è il tuo luogo all\'aperto preferito dove vorresti fare l\'amore?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot94',
      text: 'Ti ecciterebbe fare l\'amore davanti a un camino o sotto le stelle?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot95',
      text: 'Qual è il tuo scenario preferito che coinvolge cibo o dolci?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot96',
      text: 'Ti piacerebbe provare un massaggio erotico completo?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot97',
      text: 'Qual è il momento del giorno in cui ti senti più audace e provocante?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot98',
      text: 'Ti ecciterebbe un weekend completamente dedicato solo a noi due a letto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot99',
      text: 'Qual è la cosa più intima che vorresti condividere con me stasera?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot100',
      text: 'Se potessi realizzare una tua fantasia sessuale proprio ora, quale sceglieresti?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    
    // Bonus domande (101-105)
    RitualQuestion(
      id: 'hot101',
      text: 'Qual è il tuo segreto più hot che non hai mai condiviso con nessuno?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot102',
      text: 'C\'è qualcosa che ti imbarazza eccitarti ma che in realtà ti piace molto?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot103',
      text: 'Qual è il dettaglio più piccolo di me che ti fa impazzire sessualmente?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot104',
      text: 'Se dovessi descrivere il nostro sesso con tre parole, quali sarebbero?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
    RitualQuestion(
      id: 'hot105',
      text: 'Qual è la promessa più hot che vorresti farmi per stasera?',
      category: QuestionCategory.body,
      isSpicy: true,
    ),
  ];

  // Mock pact choices
  final List<PactChoice> _pactChoices = const [
    PactChoice(id: 'p1', optionA: 'Alba insieme', optionB: 'Tramonto insieme'),
    PactChoice(id: 'p2', optionA: 'Viaggiare', optionB: 'Restare a casa'),
    PactChoice(id: 'p3', optionA: 'Film romantico', optionB: 'Avventura'),
    PactChoice(id: 'p4', optionA: 'Mare', optionB: 'Montagna'),
    PactChoice(id: 'p5', optionA: 'Cena a lume di candela', optionB: 'Picnic sotto le stelle'),
    PactChoice(id: 'p6', optionA: 'Ballo lento', optionB: 'Passeggiata notturna'),
    PactChoice(id: 'p7', optionA: 'Cucinare insieme', optionB: 'Ordinare e coccolarsi'),
    PactChoice(id: 'p8', optionA: 'Lettera d\'amore', optionB: 'Messaggio vocale'),
    PactChoice(id: 'p9', optionA: 'Abbraccio lungo', optionB: 'Bacio dolce'),
    PactChoice(id: 'p10', optionA: 'Silenzio condiviso', optionB: 'Conversazione profonda'),
  ];

  // Mock challenges
  final List<RitualChallenge> _challenges = const [
    RitualChallenge(
      id: 'c1',
      text: 'Scrivi tre parole che descrivono cosa provi in questo momento per il tuo partner.',
      type: 'emotional',
      intensity: 1,
    ),
    RitualChallenge(
      id: 'c2',
      text: 'Registra un audio di 30 secondi dicendo cosa ami del vostro rapporto.',
      type: 'creative',
      intensity: 1,
    ),
    RitualChallenge(
      id: 'c3',
      text: 'Disegna un simbolo che rappresenta il vostro amore.',
      type: 'creative',
      intensity: 1,
    ),
    RitualChallenge(
      id: 'c4',
      text: 'Scrivi un haiku dedicato al tuo partner.',
      type: 'creative',
      intensity: 2,
    ),
    RitualChallenge(
      id: 'c5',
      text: 'Condividi una foto di qualcosa che ti ricorda il tuo partner oggi.',
      type: 'emotional',
      intensity: 1,
    ),
  ];

  // Poetic codex templates
  final List<String> _codexTemplates = const [
    'Nel giardino segreto delle anime, {tigre} e {quokka} hanno danzato sotto stelle di cristallo. Le loro parole, "{tigreWord}" e "{quokkaWord}", si sono intrecciate come rami di un albero antico, formando un simbolo di {symbol}.',
    'Due cuori battono all\'unisono nel tempio del silenzio. {tigre}, custode della fiamma, e {quokka}, guardiano della luce, hanno sigillato questo giorno con le parole sacre: "{tigreWord}" e "{quokkaWord}". Il loro legame brilla con intensità {percentage}%.',
    'Sotto il velo della notte, le anime di {tigre} e {quokka} si sono cercate e trovate. Con "{tigreWord}" e "{quokkaWord}" hanno scritto un nuovo capitolo nel Codex dell\'Amore Eterno. Simbolo rivelato: {symbol}.',
    'Le stelle hanno osservato mentre {tigre} e {quokka} compivano il loro rituale quotidiano. Le parole "{tigreWord}" e "{quokkaWord}" echeggeranno per sempre nelle sale del loro Codex personale. Compatibilità: {percentage}%.',
  ];

  RitualQuestion getTodaysQuestion({bool intimacyMode = false}) {
    if (intimacyMode) {
      return _spicyQuestions[_random.nextInt(_spicyQuestions.length)];
    }
    return _questions[_random.nextInt(_questions.length)];
  }

  List<PactChoice> getPactChoices({bool extended = false}) {
    if (extended) {
      return _pactChoices;
    }
    return _pactChoices.take(5).toList();
  }

  RitualChallenge getTodaysChallenge() {
    return _challenges[_random.nextInt(_challenges.length)];
  }

  int calculateCompatibility(PattoPhase patto, {bool intimacyMode = false}) {
    if (patto.choices.isEmpty) return 0;
    int aligned = patto.choices.where((c) => c.isAligned).length;
    int baseScore = ((aligned / patto.choices.length) * 100).round();
    
    // Bonus del 20% se in modalità intimacy
    if (intimacyMode) {
      baseScore = (baseScore * 1.2).round();
      if (baseScore > 100) baseScore = 100; // Cap a 100%
    }
    
    return baseScore;
  }

  CompatibilitySymbol getSymbol(int percentage) {
    if (percentage >= 80) return CompatibilitySymbol.star;
    if (percentage >= 60) return CompatibilitySymbol.circle;
    if (percentage >= 40) return CompatibilitySymbol.triangle;
    return CompatibilitySymbol.raven;
  }

  String generateCodexEntry({
    required String tigreName,
    required String quokkaName,
    required String tigreWord,
    required String quokkaWord,
    required int percentage,
    required CompatibilitySymbol symbol,
  }) {
    final template = _codexTemplates[_random.nextInt(_codexTemplates.length)];
    return template
        .replaceAll('{tigre}', tigreName)
        .replaceAll('{quokka}', quokkaName)
        .replaceAll('{tigreWord}', tigreWord)
        .replaceAll('{quokkaWord}', quokkaWord)
        .replaceAll('{percentage}', percentage.toString())
        .replaceAll('{symbol}', symbol.name);
  }

  // Mock current user
  User getCurrentUser() {
    return User(
      id: 'user1',
      email: 'tigre@example.com',
      displayName: 'Nick',
      role: UserRole.tigre,
      roomId: 'room1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  // Mock partner
  User getPartner() {
    return User(
      id: 'user2',
      email: 'quokka@example.com',
      displayName: 'Mary',
      role: UserRole.quokka,
      roomId: 'room1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  // Mock room con progressione (supporta Supabase se configurato)
  Future<Room> getCurrentRoom({String? userId}) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized && userId != null) {
      try {
        final roomData = await _supabaseService.getCurrentRoom(userId);
        if (roomData != null) {
          return Room(
            id: roomData['id'],
            inviteCode: roomData['invite_code'] ?? 'AMORE-2024',
            tigreUserId: roomData['tiger_id'],
            quokkaUserId: roomData['quokka_id'],
            isLocked: true,
            intimacyMode: false,
            figEndMode: true,
            createdAt: DateTime.parse(roomData['created_at']),
            completedDays: roomData['completed_days'] ?? 0,
            totalHarmonyScore: roomData['total_harmony_score'] ?? 0,
            lastRitualDate: roomData['last_ritual_date'] != null 
                ? DateTime.parse(roomData['last_ritual_date'])
                : null,
            ritualsCompletedToday: roomData['rituals_completed_today'] ?? 0,
            currentStreak: roomData['current_streak'] ?? 0,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore recupero room da Supabase: $e');
        }
        // Fallback a locale
      }
    }
    
    // Modalità locale: usa SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final completedDays = prefs.getInt('completed_days') ?? 0;
    final totalHarmony = prefs.getInt('total_harmony') ?? 0;
    final lastRitualString = prefs.getString('last_ritual_date');
    final ritualsToday = prefs.getInt('rituals_today') ?? 0;
    final currentStreak = prefs.getInt('current_streak') ?? 0;
    
    DateTime? lastRitual;
    if (lastRitualString != null) {
      lastRitual = DateTime.parse(lastRitualString);
    }
    
    return Room(
      id: 'room1',
      inviteCode: 'AMORE-2024',
      tigreUserId: 'user1',
      quokkaUserId: 'user2',
      isLocked: true,
      intimacyMode: false,
      figEndMode: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      completedDays: completedDays,
      totalHarmonyScore: totalHarmony,
      lastRitualDate: lastRitual,
      ritualsCompletedToday: ritualsToday,
      currentStreak: currentStreak,
    );
  }

  // Completa un rituale e aggiorna la progressione
  Future<void> completeRitual(int harmonyScore) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Carica stato attuale
    int completedDays = prefs.getInt('completed_days') ?? 0;
    int totalHarmony = prefs.getInt('total_harmony') ?? 0;
    final lastRitualString = prefs.getString('last_ritual_date');
    int ritualsToday = prefs.getInt('rituals_today') ?? 0;
    
    DateTime? lastRitual;
    if (lastRitualString != null) {
      lastRitual = DateTime.parse(lastRitualString);
    }
    
    // Controlla se è un nuovo giorno
    bool isNewDay = lastRitual == null ||
        lastRitual.day != now.day ||
        lastRitual.month != now.month ||
        lastRitual.year != now.year;
    
    if (isNewDay) {
      // Nuovo giorno: incrementa giorni completati e resetta contatore
      completedDays++;
      ritualsToday = 1;
    } else {
      // Stesso giorno: incrementa solo contatore
      ritualsToday++;
    }
    
    // Aggiorna armonia totale
    totalHarmony += harmonyScore;
    
    // Calcola e aggiorna la serie consecutiva solo se è un nuovo giorno
    if (isNewDay) {
      int currentStreak = prefs.getInt('current_streak') ?? 0;
      
      // Verifica se è consecutivo (ieri)
      if (lastRitual != null) {
        final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        final lastDate = DateTime(lastRitual.year, lastRitual.month, lastRitual.day);
        
        if (lastDate.year == yesterday.year && 
            lastDate.month == yesterday.month && 
            lastDate.day == yesterday.day) {
          // Consecutivo: incrementa
          currentStreak++;
        } else {
          // Non consecutivo: resetta a 1
          currentStreak = 1;
        }
      } else {
        // Primo rituale
        currentStreak = 1;
      }
      
      await prefs.setInt('current_streak', currentStreak);
    }
    
    // Salva tutto
    await prefs.setInt('completed_days', completedDays);
    await prefs.setInt('total_harmony', totalHarmony);
    await prefs.setString('last_ritual_date', now.toIso8601String());
    await prefs.setInt('rituals_today', ritualsToday);
  }

  // Reset del viaggio
  Future<void> resetJourney({String? roomId}) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized && roomId != null) {
      try {
        await _supabaseService.resetJourney(roomId);
        notifyListeners();
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore reset viaggio su Supabase: $e');
        }
        // Fallback a locale
      }
    }
    
    // Modalità locale: reset su SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Reset progressione
    await prefs.remove('completed_days');
    await prefs.remove('total_harmony');
    await prefs.remove('last_ritual_date');
    await prefs.remove('rituals_today');
    await prefs.remove('current_streak');
    
    // Cancella TUTTI i codex locali salvati
    await prefs.remove('codex_pages');
    await prefs.remove('saved_codex');
    await prefs.remove('ritual_history');
    
    // Rimuovi anche eventuali rituali completati salvati localmente
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('ritual_') || 
          key.startsWith('codex_') || 
          key.startsWith('page_')) {
        await prefs.remove(key);
      }
    }
    
    notifyListeners();
  }

  // Calcola la serie consecutiva di giorni
  Future<int> calculateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRitualDateStr = prefs.getString('last_ritual_date');
    
    if (lastRitualDateStr == null) {
      return 0;
    }
    
    final lastRitualDate = DateTime.parse(lastRitualDateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastRitualDate.year, lastRitualDate.month, lastRitualDate.day);
    
    final daysDifference = today.difference(lastDate).inDays;
    
    // Se l'ultimo rituale è stato fatto oggi o ieri, la serie continua
    if (daysDifference <= 1) {
      return prefs.getInt('current_streak') ?? 1;
    } else {
      // Serie interrotta
      return 0;
    }
  }

  // Get current ritual
  DailyRitual? getCurrentRitual() {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    
    return DailyRitual(
      id: 'ritual_${now.day}_${now.month}',
      roomId: 'room1',
      date: now,
      currentPhase: RitualPhase.ilVelo,
      isWeekendExtended: isWeekend,
      veloPhase: VeloPhase(
        questionId: 'q1',
        question: getTodaysQuestion().text,
        category: QuestionCategory.heart,
      ),
    );
  }

  // Get past codex pages
  List<CodexPage> getCodexPages() {
    final pages = <CodexPage>[];
    final now = DateTime.now();
    
    for (int i = 1; i <= 7; i++) {
      final date = now.subtract(Duration(days: i));
      final percentage = 60 + _random.nextInt(40);
      final symbol = getSymbol(percentage);
      
      pages.add(CodexPage(
        id: 'page_$i',
        date: date,
        content: generateCodexEntry(
          tigreName: 'Nick',
          quokkaName: 'Mary',
          tigreWord: ['eternità', 'passione', 'luce', 'stelle'][_random.nextInt(4)],
          quokkaWord: ['amore', 'insieme', 'sempre', 'cuore'][_random.nextInt(4)],
          percentage: percentage,
          symbol: symbol,
        ),
        compatibilityPercentage: percentage,
        symbol: symbol,
      ));
    }
    
    return pages;
  }

  // Get ritual statistics
  Future<Map<String, dynamic>> getStatistics({String? roomId}) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized && roomId != null) {
      try {
        final stats = await _supabaseService.getStatistics(roomId);
        return {
          'totalRituals': stats['completedDays'],
          'remainingDays': stats['totalDays'] - stats['completedDays'],
          'streak': stats['streak'],
          'averageCompatibility': stats['averageHarmony'],
          'totalCodexPages': stats['codexPages'],
          'favoriteSymbol': CompatibilitySymbol.star,
        };
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore recupero statistiche da Supabase: $e');
        }
        // Fallback a locale
      }
    }
    
    // Modalità locale: calcola da SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final completedDays = prefs.getInt('completed_days') ?? 0;
    final totalHarmony = prefs.getInt('total_harmony') ?? 0;
    final averageHarmony = completedDays > 0 ? (totalHarmony / completedDays).round() : 0;
    final streak = await calculateStreak();
    
    return {
      'totalRituals': completedDays,
      'remainingDays': 365 - completedDays,
      'streak': streak,
      'averageCompatibility': averageHarmony,
      'totalCodexPages': completedDays,
      'favoriteSymbol': CompatibilitySymbol.star,
    };
  }
  
  /// Iscriviti agli aggiornamenti real-time della stanza
  Future<void> subscribeToRoom(String roomId, Function() onUpdate) async {
    await _supabaseService.subscribeToRoom(roomId, (_) {
      notifyListeners();
      onUpdate();
    });
  }
  
  /// Dispose delle subscription
  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
