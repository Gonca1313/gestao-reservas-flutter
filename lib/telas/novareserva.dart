import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detalhes.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'package:screenshot/screenshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NovaReservaPage extends StatefulWidget {
  final String nomeUtilizador;

  const NovaReservaPage({super.key, required this.nomeUtilizador});

  @override
  State<NovaReservaPage> createState() => _NovaReservaPageState();
}

class _NovaReservaPageState extends State<NovaReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _finalidadeController = TextEditingController();
  final _observacoesController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

Future<bool> _verificarDisponibilidade(
    Map<String, dynamic> item, DateTime data, String horario) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reservas')
      .where('titulo', isEqualTo: item['titulo'])
      .where('data', isEqualTo: Timestamp.fromDate(DateTime(data.year, data.month, data.day)))
      .where('horario', isEqualTo: horario)
      .where('status', isEqualTo: 'Confirmada')
      .get();

  return snapshot.docs.isEmpty;
}

  int _etapaAtual = 0;

  DateTime? _dataSelecionada;
  String? _horarioSelecionado;

  bool _aceitouTermos = false;
  bool _reservaConfirmada = false;
  bool _processandoConfirmacao = false;

  // Lista de horários disponíveis (exemplo)
  final List<String> _horariosDisponiveis = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  // Lista de itens disponíveis para reservar
  final List<Map<String, dynamic>> _itensDisponiveis = [
    {
      'titulo': 'Sala de Reuniões A',
      'descricao': 'Capacidade para 8 pessoas. Projetor incluído.',
      'local': 'Edifício Principal, 2º Andar',
      'codigo': 'RES-2024-0123',
      'icon': Icons.meeting_room,
      'cor': Colors.blue,
    },
    {
      'titulo': 'Sala de Conferências B',
      'descricao': 'Capacidade para 20 pessoas. Equipado com sistema de áudio.',
      'local': 'Edifício Anexo, 1º Andar',
      'codigo': 'RES-2024-0456',
      'icon': Icons.meeting_room,
      'cor': Colors.green,
    },
    {
      'titulo': 'Sala de Reuniões C',
      'descricao': 'Sala equipada para reuniões até 15 pessoas, com videoconferência, quadro branco e TV.',
      'local': 'Edifício Principal, 3º Andar',
      'codigo': 'RES-2024-0789',
      'icon': Icons.meeting_room,
      'cor': Colors.deepPurple,
    },
  ];

  Map<String, dynamic>? _itemSelecionado;

  @override
  void dispose() {
    _finalidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _proximaEtapa() {
    // Validações por etapa antes de avançar
    switch (_etapaAtual) {
      case 0:
        if (_dataSelecionada == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione uma data.')),
          );
          return;
        }
        if (_horarioSelecionado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione um horário.')),
          );
          return;
        }
        break;

      case 1:
        if (_itemSelecionado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione um item.')),
          );
          return;
        }
        break;

      case 2:
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (!_aceitouTermos) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você deve aceitar os termos.')),
          );
          return;
        }
        break;
    }

    if (_etapaAtual < 3) {
      setState(() {
        _etapaAtual++;
      });
    }
  }

  void _etapaAnterior() {
    if (_etapaAtual > 0) {
      setState(() {
        _etapaAtual--;
      });
    }
  }

  Future<void> _confirmarReserva() async {
  if (_processandoConfirmacao) return; // Evita chamadas múltiplas
  _processandoConfirmacao = true;

  setState(() {
    _reservaConfirmada = true;
  });

  final reserva = {
    'utilizador': widget.nomeUtilizador,
    'titulo': _itemSelecionado!['titulo'],
    'local': _itemSelecionado!['local'],
    'data': _dataSelecionada,
    'horario': _horarioSelecionado,
    'finalidade': _finalidadeController.text,
    'observacoes': _observacoesController.text,
    'status': 'Confirmada',
    'cor': _itemSelecionado!['cor']?.value,
    'qrData': '''
Item: ${_itemSelecionado!['titulo']}
Local: ${_itemSelecionado!['local']}
Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}
Horário: $_horarioSelecionado
Código: ${_itemSelecionado!['codigo']}
Finalidade: ${_finalidadeController.text}
''',
    'horaCriacao': FieldValue.serverTimestamp(),
  };

  try {
    // 🔹 Guarda a reserva
    await FirebaseFirestore.instance.collection('reservas').add(reserva);

    // 🔹 Cria a notificação da reserva
    await FirebaseFirestore.instance.collection('notificacoes').add({
      'utilizador': widget.nomeUtilizador,
      'titulo': 'Reserva Confirmada',
      'mensagem':
          'A sua reserva para ${reserva['titulo']} em ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year} às $_horarioSelecionado foi confirmada.',
      'tipo': 'reserva',
      'hora': Timestamp.now(),
    });
  } catch (e) {
    print('Erro ao guardar reserva ou notificação: $e');
  }

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  setState(() {
    _reservaConfirmada = false;
  });

  _processandoConfirmacao = false;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Reserva Confirmada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A sua reserva foi confirmada!\n\n'
            'Sala: ${reserva['titulo']}\n'
            'Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}\n'
            'Horário: $_horarioSelecionado',
          ),
          const SizedBox(height: 16),
          Screenshot(
            controller: _screenshotController,
            child: SizedBox(
              height: 160,
              width: 160,
              child: qr_flutter.QrImageView(
                data: reserva['qrData'],
                version: qr_flutter.QrVersions.auto,
                gapless: false,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final image = await _screenshotController.capture();
            if (image != null) {
              Navigator.of(context).pop();
              Navigator.of(context).pop(reserva);
            }
          },
          child: const Text('OK'),
        )
      ],
    ),
  );
}



  Widget _buildSelecaoDataHorario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao('Selecione a Data'),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final hoje = DateTime.now();
              final data = await showDatePicker(
                context: context,
                initialDate: _dataSelecionada ?? hoje,
                firstDate: hoje,
                lastDate: hoje.add(const Duration(days: 365)),
              );
              if (data != null) {
                setState(() {
                  _dataSelecionada = data;
                  _horarioSelecionado = null; // Reset horário ao mudar data
                });
              }
            },
            child: Text(_dataSelecionada == null
                ? 'Escolher data'
                : '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'),
          ),
        ),
        const SizedBox(height: 24),
        if (_dataSelecionada != null) ...[
          _tituloSecao('Selecione o Horário'),
          Wrap(
            spacing: 10,
            children: _horariosDisponiveis.map((horario) {
              final selecionado = horario == _horarioSelecionado;
              return ChoiceChip(
                label: Text(horario),
                selected: selecionado,
                onSelected: (_) {
                  setState(() {
                    _horarioSelecionado = horario;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSelecaoItem() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _tituloSecao('Selecionar Sala ou Equipamento'),
      SizedBox(
        height: 280,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _itensDisponiveis.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = _itensDisponiveis[index];
            final isSelected = _itemSelecionado == item;
            return SizedBox(
              width: 240,
              child: _buildGridItem(item, () {
                setState(() {
                  _itemSelecionado = item;
                });
              }, isSelected),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  DetalhesdaSalaEquipamentoWidget(showDrawer: false, nomeUtilizador: widget.nomeUtilizador),
              ),
            );
          },
          child: const Text('Mais informações'),
        ),
      ),
    ],
  );
}


  Widget _buildFormularioReserva() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _tituloSecao('Informações Adicionais'),
          _campoTexto(
            label: 'Finalidade da Reserva',
            hint: 'Ex: Reunião de equipe, Apresentação...',
            controller: _finalidadeController,
          ),
          _campoTexto(
            label: 'Observações',
            hint: 'Alguma observação ou requisito especial?',
            controller: _observacoesController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _tituloSecao('Termos e Condições'),
          const Text(
            'Ao confirmar esta reserva, você concorda com os termos de uso e políticas de cancelamento. Cancelamentos devem ser feitos com pelo menos 24 horas de antecedência para garantir o bom funcionamento do sistema e permitir uma melhor gestão de recursos.',
            style: TextStyle(height: 1.5),
          ),
          CheckboxListTile(
            title: const Text('Aceito os termos e condições'),
            value: _aceitouTermos,
            onChanged: (bool? value) {
              setState(() {
                _aceitouTermos = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumoConfirmacao() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _tituloSecao('Resumo da Reserva'),
      _resumoLinha('Item Reservado:', _itemSelecionado?['titulo'] ?? '-'),
      _resumoLinha('Local:', _itemSelecionado?['local'] ?? '-'),
      _resumoLinha(
        'Data:',
        _dataSelecionada == null
            ? '-'
            : '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
      ),
      _resumoLinha('Horário:', _horarioSelecionado ?? '-'),
      _resumoLinha('Código:', _itemSelecionado?['codigo'] ?? '-'),
      _resumoLinha('Finalidade:', _finalidadeController.text.isEmpty ? '-' : _finalidadeController.text),
      _resumoLinha('Observações:', _observacoesController.text.isEmpty ? '-' : _observacoesController.text),
      const SizedBox(height: 24),
      const SizedBox.shrink(), // Removido o botão duplicado
    ],
  );
}


  Widget _buildGridItem(Map<String, dynamic> item, VoidCallback onSelect, bool isSelected) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(item['icon'] ?? Icons.meeting_room, color: item['cor'] ?? Colors.blue, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Disponível',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item['titulo'],
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item['descricao'], style: TextStyle(color: Colors.grey[600])),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
  if (_dataSelecionada == null || _horarioSelecionado == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione data e horário antes de escolher o item.')),
    );
    return;
  }

  final disponivel = await _verificarDisponibilidade(item, _dataSelecionada!, _horarioSelecionado!);

  if (!disponivel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['titulo']} já está reservado nesse horário.')),
    );
    return;
  }

  onSelect();
},

                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blueAccent : Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isSelected ? 'Selecionado' : 'Selecionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumoLinha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          SizedBox(
            width: 180,
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _campoTexto({
  required String label,
  String? hint,
  required TextEditingController controller,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Reserva'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildEtapa(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_etapaAtual > 0)
              ElevatedButton(
                onPressed: _etapaAnterior,
                child: const Text('Voltar'),
              )
            else
              const SizedBox(width: 100), // Placeholder para alinhamento

            ElevatedButton(
  onPressed: (_etapaAtual == 3 && _reservaConfirmada)
    ? null
    : (_etapaAtual == 3 ? _confirmarReserva : _proximaEtapa),
  child: _etapaAtual == 3
      ? (_reservaConfirmada
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text('Confirmar'))
      : const Text('Avançar'),
),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapa() {
    switch (_etapaAtual) {
      case 0:
        return _buildSelecaoDataHorario();
      case 1:
        return _buildSelecaoItem();
      case 2:
        return _buildFormularioReserva();
      case 3:
        return _buildResumoConfirmacao();
      default:
        return const SizedBox();
    }
  }
}
