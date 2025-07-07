part of 'review_request_widgets.dart';

class InvoiceDetailForm extends StatefulWidget {
  // final bool withInspection;
  final Lista inspection;
  final DataClientForm dataClientForm;
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final ValueChanged<int> onJumpFlag;
  const InvoiceDetailForm(
      {Key? key,
      // required this.withInspection,
      required this.dataClientForm,
      required this.inspection,
      required this.onNextFlag,
      required this.onJumpFlag,
      required this.onBackFlag})
      : super(key: key);

  @override
  State<InvoiceDetailForm> createState() => _InvoiceDetailFormState();
}

class _InvoiceDetailFormState
    extends State<InvoiceDetailForm> /*with AutomaticKeepAliveClientMixin*/ {
  //? ATAJOS
  TextStyle titleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w900,
      color: AppConfig.appThemeConfig.secondaryColor);
  TextStyle itemHeadingStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );
  TextStyle itemValueStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  Divider divider = Divider(
    height: 20,
    color: AppConfig.appThemeConfig.secondaryColor,
  );
  ContinueInspection inspectionData = ContinueInspection();

  //? Variables
  String selectedBranch = '';
  String selectedBranchValue = '';
  String selectedProduct = '';
  String selectedProductValue = '';
  String selectedProductCotizador = '';
  String selectedDeductible = '';
  String? selectedDeductibleValue;
  String selectedPaymentMethod = '';
  String selectedPaymentMethodValue = '';
  String selectedFee = 'Seleccionar cuotas';
  String selectedFeeValue = '';
  List<S2Choice<String>> branchs = [];
  List<S2Choice<String>> products = [];
  List<S2Choice<String>> deductibles = [];
  List<S2Choice<String>> paymentMethods = [];
  List<S2Choice<String>> fees = [];
  String paymentType = '';
  //? Invoice Items
  double sumAssured = 0.0;
  double netPremium = 0.0; //?Prima Neta
  double superBco = 0.0;
  double taxScc = 0.0;
  double rigthOfIssue = 0.0; //? Derecho de emision
  double cSI = 0.0; //? Cargo sujueto a iva
  double tax = 0.0; //? iva
  double cNSI = 0.0; //? Cargo no sujeto a iva
  double totalPremium = 0.0; //?Prima total
  List<DataRow> coverge = [];
  //? Validation
  bool formCompleted = false;
  //? CARGANDO DEDUCIBLES DEL PRODUCTO
  bool loadingDOP = false;
  //? Mantener configuración inicial: Rama, producto y deducible
  bool keepInitial = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rrp = Provider.of<ReviewRequestProvider>(context, listen: false);
      if (rrp.loadInvoiceData) {
        _getDataStorage();
        _loadSelects();
      }
    });

    super.initState();
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    if (continueInspection != null) {
      inspectionData = continueInspection;
    }
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }

    inspectionData.deducible = selectedDeductibleValue ?? "0";
    inspectionData.codRamo = selectedBranchValue;
    inspectionData.codProducto = selectedProductValue;
    inspectionData.producto = selectedProduct;
    inspectionData.codFormaPago = selectedPaymentMethodValue;
    inspectionData.cuotas = (paymentType == '0') ? '' : selectedFeeValue;
    inspectionData.idMedioCobro = paymentType;
    // inspectionData.valorSumaAsegurada = sumAssured.toString();

    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
  }

  _loadSelects() async {
    //?Cargamos ramos
    selectedBranch = widget.inspection.ramo;
    selectedBranchValue = widget.inspection.idRamo;
    branchs = widget.dataClientForm.listaRamo!
        .map((e) => S2Choice(value: e.codigo, title: e.descripcion))
        .toList();
    //? Cargamos productos
    await _filterProduct(true);
    // //? Cargamos los deducibles
    // selectedDeductible = widget.inspection.datosVehiculo.deducible;
    // selectedDeductibleValue = selectedDeductible;
    // _loadDeductibles();
    //? Cargamos los metodos de pago
    selectedPaymentMethod = 'Seleccione forma de pago';
    selectedPaymentMethodValue = '';
    paymentMethods = widget.dataClientForm.listaFPagos
        .map((e) => S2Choice(value: e.codigo, title: e.descripcion))
        .toList();
    // setState(() {});
    // _getInvoiceDetails();
  }

  _cleanDeductibles() {
    selectedDeductible = "Seleccione deducible";
    selectedDeductibleValue = "0";
    deductibles = [];
  }

  _loadDeductibles() async {
    final cInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    loadingDOP = true;
    setState(() {});
    final response = await RequestReviewService()
        .getDeductibles(context, double.parse(cInspection!.valorSugerido!));
    if (!response.error) {
      deductibles = response.data!
          .map((e) => S2Choice(
              value: e.valDeducible.toString(),
              title: e.valDeducible.toString()))
          .toList();
    }
    loadingDOP = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    final size = MediaQuery.of(context).size;
    TextStyle selectTitleStyle = const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DETALLE DE COMPRA', style: titleStyle),
              divider,
              _selectBranch(selectTitleStyle),
              if (products.isNotEmpty) _selectProduct(selectTitleStyle),
              if (deductibles.isEmpty &&
                  loadingDOP == false &&
                  selectedProductCotizador == "SI")
                _reloadDeductible(),
              if (deductibles.isNotEmpty) _selectDeductible(selectTitleStyle),
              divider,
              _sumAssured(),
              divider,
              _detailInvoice(),
              const SizedBox(
                height: 5,
              ),
              _total(totalPremium),
              const SizedBox(
                height: 10,
              ),
              _showAllCoverage(),
              divider,
              _selectPaymentMethod(selectTitleStyle),
              divider,
              _paymentType(),
              if (paymentType == '1') _selectFee(selectTitleStyle),
              divider,
              _navigationButtons()
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;

  Column _selectPaymentMethod(TextStyle selectTitleStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          'Forma de pago',
          style: selectTitleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        SelectWidget(
            title: 'Seleccione Forma de Pago',
            options: paymentMethods,
            optionSelected: (v) {
              selectedPaymentMethod = v!.title!;
              selectedPaymentMethodValue = v.value!;
              paymentType = '';
              setState(() {});
              _checkIfFormCompleted();
            },
            textShow: selectedPaymentMethod,
            value: selectedPaymentMethodValue),
      ],
    );
  }

  Widget _selectFee(TextStyle selectTitleStyle) {
    return FadeInRight(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          'Cuotas Seleccionadas',
          style: selectTitleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        SelectWidget(
            title: 'Seleccionar Cuotas',
            options: fees,
            optionSelected: (v) {
              selectedFee = v!.title!;
              selectedFeeValue = v.value!;
              _checkIfFormCompleted();
              setState(() {});
            },
            textShow: selectedFee,
            value: selectedFeeValue),
      ]),
    );
  }

  Widget _reloadDeductible() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
              onPressed: () {
                if (keepInitial) {
                  _getDataStorage();
                  _loadSelects();
                } else {
                  _cleanDeductibles();
                  _cleanInvoiceItems();
                  _loadDeductibles();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Recargar borrador"),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.cached)
                ],
              )),
        )
      ],
    );
  }

  Column _selectDeductible(TextStyle selectTitleStyle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 8,
      ),
      Text(
        'Deducible Seleccionado',
        style: selectTitleStyle,
      ),
      const SizedBox(
        height: 8,
      ),
      SelectWidget(
          title: 'Seleccionar Deducible',
          options: deductibles,
          optionSelected: (v) {
            selectedDeductible = v!.title!;
            selectedDeductibleValue = v.value!;

            _getInvoiceDetails();
            _checkIfFormCompleted();
            setState(() {});
          },
          textShow: selectedDeductible,
          value: selectedDeductibleValue!),
    ]);
  }

  Column _selectProduct(TextStyle selectTitleStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          'Producto Seleccionado',
          style: selectTitleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        SelectWidget(
            title: 'Seleccionar Producto',
            options: products,
            optionSelected: (v) {
              selectedProduct = v!.title!;
              selectedProductValue = v.value!;
              selectedProductCotizador = v.meta;
              // _getInvoiceDetails();

              _cleanInvoiceItems();
              if (v.meta == "SI") {
                //? Previamente hemos guardado en meta el valor de producto cotizador
                _cleanDeductibles();
                _loadDeductibles();
              } else if (v.meta == "NO") {
                _cleanDeductibles();
                _getInvoiceDetails();
              }
              keepInitial = false;

              _checkIfFormCompleted();
              setState(() {});
            },
            textShow: selectedProduct,
            value: selectedProductValue),
      ],
    );
  }

  Column _selectBranch(TextStyle selectTitleStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          'Ramo Seleccionado',
          style: selectTitleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        SelectWidget(
            title: 'Seleccionar Ramo',
            options: branchs,
            optionSelected: (v) {
              selectedBranch = v!.title!;
              selectedBranchValue = v.value!;
              _cleanInvoiceItems();
              _filterProduct(false);
              _checkIfFormCompleted();
              setState(() {});
            },
            textShow: selectedBranch,
            value: selectedBranchValue),
      ],
    );
  }

  _filterProduct(bool isInitialRequest) {
    List<S2Choice<String>> productsFiltered = [];
    for (var e in widget.dataClientForm.listaProducto) {
      if (selectedBranchValue == e.codRamo) {
        var option = S2Choice(
            value: e.codProducto,
            title: e.descripcion,
            meta: e.esProdCotizador);
        productsFiltered.add(option);
        if (isInitialRequest) {
          // print("SOY REQUEST INICIAL");
          if (e.codProducto == widget.inspection.idProducto) {
            // print("SOY igual: ${e.codProducto }");
            selectedProduct = e.descripcion;
            selectedProductValue = e.codProducto;
            selectedProductCotizador = e.esProdCotizador;
            if (e.esProdCotizador == 'SI') {
              // print("SOY PRODUCTO COTIZADORRRRR");
              //? Cargamos los deducibles
              selectedDeductible = widget.inspection.datosVehiculo.deducible;
              selectedDeductibleValue = selectedDeductible;

              _loadDeductibles();
              //   if(selectedDeductibleValue!=null){
              //  _getInvoiceDetails();
              //   }
            } else {
              _cleanDeductibles();
              _cleanInvoiceItems();
            }
            _getInvoiceDetails();
          }
        }
      }
    }

    if (!isInitialRequest) {
      selectedProduct = 'Seleccione Producto';
      selectedProductValue = '';
    }

    products = productsFiltered;
    if (products.isEmpty) {
      _cleanDeductibles();
      _cleanInvoiceItems();
      const snackBar = SnackBar(
        content: Text('No hay productos para este ramo!'),
      );

      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(snackBar);
    }
  }

  Widget _sumAssured() {
    return SizedBox(
        // height: 59,
        width: double.infinity,
        // color: Colors.red,
        child: Column(
          children: [
            Text('SUMA ASEGURADO', style: titleStyle),
            const SizedBox(
              height: 5,
            ),
            Text('\$ ${sumAssured.toStringAsFixed(2)}', style: titleStyle),
          ],
        ));
  }

  _cleanInvoiceItems() {
    sumAssured = 0.00;
    netPremium = 0.00;
    superBco = 0.00;
    taxScc = 0.00;
    rigthOfIssue = 0.00;
    cSI = 0.00;
    tax = 0.00;
    cNSI = 0.00;
    totalPremium = 0.00;
    setState(() {});
  }

  _getInvoiceDetails() async {
    final cInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    Helper.logger.w('valor cargado: ${cInspection?.valorSugerido}');
    List<CobOriginale> cobAdicionales = [];
    final lists = Helper.sortCoverages(
        accessoriesVehicles: (cInspection!.accessoriesVehicles != null)
            ? cInspection.accessoriesVehicles!
            : [],
        listName: "adicionales");

    cobAdicionales = lists[0];

    final data = <String, dynamic>{
      "codProducto": selectedProductValue,
      "sumaAseg": cInspection.valorSugerido!,
      "capacidadPasajeros": cInspection.capacidadPasajeros!,
      "anio": cInspection.anio!,
      "modelo": cInspection.codModelo!,
      "marca": cInspection.codMarca!,
      "caracPol": (widget.inspection.idTipoFlujo == 6) ? 'A' : 'N',
      "procedencia": cInspection.codPaisO!,
      // "fechaNacimiento": cInspection.fechaNacimiento!.substring(0, 4),
      "fechaNacimiento": cInspection.fechaNacimiento!,
      "agencia": widget.inspection.idAgencia,
      "fecInvig": cInspection.fechaInicioVigencia!,
      "fecFinvig": cInspection.fechaFinVigencia!,
      "deducible": selectedDeductibleValue ?? "0",
      "cobAdicionales": cobAdicionales
    };
    // print("DATAAAAA");
    // inspect(data);
    final response = await RequestReviewService().getInvoiceData(context, data);

    if (!response.error) {
      Helper.logger.w('valor asegurado: ${cInspection.valorSumaAsegurada}');
      sumAssured = response.data!.sumaAseg;
      // sumAssured = double.parse(cInspection.valorSumaAsegurada!);
      netPremium = response.data!.primaNeta;
      superBco = response.data!.impSuper;
      taxScc = response.data!.impScc;
      rigthOfIssue = response.data!.demision;
      cSI = response.data!.cargoSujetoIva;
      tax = response.data!.iva;
      cNSI = response.data!.cargoNosujetoIva;
      totalPremium = response.data!.primaTotal;
      coverge = response.data!.coberturas!
          .map(
            (e) => DataRow(cells: [
              DataCell(
                SizedBox(
                    child: Text(e.cobertura,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppConfig.appThemeConfig.secondaryColor),
                        textAlign: TextAlign.left)),
              ),
              DataCell(Checkbox(
                  value: (e.marIncl != null) ? true : false, onChanged: null)),
              DataCell(Text('${e.capAseg ?? ""}',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppConfig.appThemeConfig.secondaryColor),
                  textAlign: TextAlign.center)),
              DataCell(Text((e.tasaPrima != null) ? '${e.tasaPrima}' : '',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppConfig.appThemeConfig.secondaryColor),
                  textAlign: TextAlign.center)),
              DataCell(Text('${e.primBas ?? ''}',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppConfig.appThemeConfig.secondaryColor),
                  textAlign: TextAlign.center)),
            ]),
          )
          .toList();
      setState(() {});
    } else {
      _cleanDeductibles();
      _cleanInvoiceItems();
      selectedProductValue = '';
      _checkIfFormCompleted();
      setState(() {});
    }
  }

  _detailInvoice() {
    const spacing = SizedBox(height: 2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _items('Prima Neta', netPremium),
          spacing,
          _items('Contr. Super Bco.', superBco),
          spacing,
          _items('Impuesto SCC', taxScc),
          spacing,
          _items('Derecho Emision', rigthOfIssue),
          spacing,
          _items('O. Cargo Suj. IVA', cSI),
          spacing,
          _items('I V A', tax),
          spacing,
          _items('O. Cargo No Sub. Iva', cNSI),
        ],
      ),
    );
  }

  _items(String heading, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(heading, style: itemHeadingStyle),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: itemValueStyle,
        )
      ],
    );
  }

  Widget _total(double total) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      width: double.infinity,
      color: AppConfig.appThemeConfig.secondaryColor,
      child: Text('PRIMA TOTAL  \$${total.toStringAsFixed(2)}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
    );
  }

  _showAllCoverage() {
    return Align(
      child: InkWell(
        onTap: () {
          final fp = Provider.of<FunctionalProvider>(context, listen: false);

          fp.showAlert(content: AlertCoverages(coverages: coverge));
        },
        child: Text(
          'Ver coberturas',
          style: TextStyle(
            color: AppConfig.appThemeConfig.primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  _paymentType() {
    return Column(children: [
      Text("Tipo de Pago",
          style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppConfig.appThemeConfig.secondaryColor)),
      _payment('0', 'Contado'),
      //? si la forma de pago es diferente de 19 puedo elegir las cuotas
      if (selectedPaymentMethodValue != '19') _payment('1', 'Cuotas'),
    ]);
  }

  Row _payment(String value, String title) {
    return Row(children: [
      Radio(
          value: value,
          groupValue: paymentType,
          onChanged: (String? value) {
            paymentType = value!;
            setState(() {});
            if (paymentType == '1') {
              selectedFee = 'Seleccionar cuotas';
              selectedFeeValue = '';
              _getCuotas();
            }
            _checkIfFormCompleted();
          }),
      Text(title)
    ]);
  }

  _getCuotas() async {
    final response = await RequestReviewService()
        .getCuotas(context, widget.inspection.idAgencia);
    if (!response.error) {
      fees = response.data!;
      setState(() {});
    }
  }

  void _checkIfFormCompleted() {
    if (selectedBranchValue.isNotEmpty &&
        selectedProductValue.isNotEmpty &&
        // selectedDeductibleValue.isNotEmpty &&
        typeProductSelected() &&
        selectedPaymentMethodValue.isNotEmpty) {
      if (paymentType.isNotEmpty) {
        if (paymentType == '0') {
          formCompleted = true;
        } else if (paymentType == '1' && selectedFeeValue.isNotEmpty) {
          formCompleted = true;
        } else {
          formCompleted = false;
        }
      } else {
        formCompleted = false;
      }
    } else {
      formCompleted = false;
    }
    setState(() {});
  }

  bool typeProductSelected() {
    if (selectedProductCotizador == "SI") {
      if (selectedDeductibleValue!.isNotEmpty &&
          selectedDeductibleValue != "0") {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Widget _navigationButtons() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: TextButton(
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: AppConfig.appThemeConfig.secondaryColor),
              onPressed: () {
                if (widget.inspection.idTipoFlujo == 5) {
                  widget.onBackFlag(true);
                } else {
                  widget.onJumpFlag(3); // sin inspeccion
                }
              },
              child: const Text(
                'REGRESAR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (formCompleted)
            FadeInRight(
              child: Container(
                margin: const EdgeInsets.all(4),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      backgroundColor: AppConfig.appThemeConfig.primaryColor),
                  onPressed: () {
                    Helper.dismissKeyboard(context);
                    _saveDataStorage();
                    widget.onNextFlag(true);
                  },
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
