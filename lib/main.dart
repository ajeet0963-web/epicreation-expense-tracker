import 'package:flutter/material.dart';
void main()=>runApp(const App());

class Expense {
  Expense(this.title,this.amount,this.category);
  final String title,category; final double amount; String status='Submitted';
}

class App extends StatelessWidget {
  const App({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,
    theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff0b5cab)),useMaterial3:true),
    home:const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState()=>_LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final pin=TextEditingController();
  String? error;
  void adminLogin(){
    if(pin.text=='1234'){
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Home(isAdmin:true)));
    }else{
      setState(()=>error='Incorrect PIN');
    }
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(
      constraints:const BoxConstraints(maxWidth:420),
      child:Column(children:[
        const CircleAvatar(radius:38,backgroundColor:Color(0xff0b5cab),child:Icon(Icons.account_balance_wallet,color:Colors.white,size:38)),
        const SizedBox(height:18),
        const Text('EpiCreation Expenses',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),
        const Text('Company Expense Tracker'),
        const SizedBox(height:30),
        TextField(controller:pin,obscureText:true,keyboardType:TextInputType.number,maxLength:4,
          decoration:InputDecoration(labelText:'Admin PIN',errorText:error,border:const OutlineInputBorder(),prefixIcon:const Icon(Icons.lock))),
        SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:adminLogin,icon:const Icon(Icons.admin_panel_settings),label:const Text('Admin Login'))),
        const SizedBox(height:12),
        SizedBox(width:double.infinity,child:OutlinedButton.icon(
          onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Home(isAdmin:false))),
          icon:const Icon(Icons.person),label:const Text('Continue as Employee'))),
        const SizedBox(height:20),
        const Text('Testing Admin PIN: 1234',style:TextStyle(color:Colors.grey))
      ]))))));
}

class Home extends StatefulWidget {
  const Home({super.key,required this.isAdmin});
  final bool isAdmin;
  @override State<Home> createState()=>_HomeState();
}

class _HomeState extends State<Home> {
  int tab=0;
  final items=<Expense>[
    Expense('Local Transport',850,'Travel'),
    Expense('Printing Material',2450,'Production')
  ];

  void logout()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const LoginPage()));

  void addExpense(){
    final title=TextEditingController(),amount=TextEditingController();
    String category='Travel';
    showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>StatefulBuilder(
      builder:(ctx,modal)=>Padding(
        padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(ctx).viewInsets.bottom+20),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          const Text('Submit Expense',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
          const SizedBox(height:16),
          TextField(controller:title,decoration:const InputDecoration(labelText:'Expense title',border:OutlineInputBorder())),
          const SizedBox(height:12),
          TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Amount (₹)',border:OutlineInputBorder())),
          const SizedBox(height:12),
          DropdownButtonFormField<String>(initialValue:category,
            decoration:const InputDecoration(labelText:'Category',border:OutlineInputBorder()),
            items:['Travel','Food','Production','Accommodation','Office','Other'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
            onChanged:(v)=>modal(()=>category=v!)),
          const SizedBox(height:12),
          OutlinedButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Bill upload will connect to Azure in production.'))),icon:const Icon(Icons.receipt_long),label:const Text('Attach Bill')),
          const SizedBox(height:12),
          SizedBox(width:double.infinity,child:FilledButton(onPressed:(){
            final value=double.tryParse(amount.text);
            if(title.text.trim().isEmpty||value==null||value<=0)return;
            setState(()=>items.insert(0,Expense(title.text.trim(),value,category)));
            Navigator.pop(ctx);
          },child:const Text('Submit to Accounts')))
        ]))));
  }

  @override Widget build(BuildContext context){
    final pages=<Widget>[expenses()];
    if(widget.isAdmin)pages.add(approvals());
    pages.add(profile());
    return Scaffold(
      appBar:AppBar(title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('EpiCreation Expenses',style:TextStyle(fontWeight:FontWeight.bold)),
        Text(widget.isAdmin?'Administrator':'Employee',style:const TextStyle(fontSize:12))
      ]),actions:[IconButton(onPressed:logout,icon:const Icon(Icons.logout),tooltip:'Logout')]),
      body:pages[tab],
      floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:addExpense,icon:const Icon(Icons.add),label:const Text('Add Expense')):null,
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:[
        const NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'Expenses'),
        if(widget.isAdmin)const NavigationDestination(icon:Icon(Icons.approval_outlined),label:'Approvals'),
        const NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile')
      ]));
  }

  Widget expenses(){
    final total=items.fold<double>(0,(s,e)=>s+e.amount);
    return ListView(padding:const EdgeInsets.all(16),children:[
      Card(color:const Color(0xff0b5cab),child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Total submitted',style:TextStyle(color:Colors.white70)),
        Text('₹'+total.toStringAsFixed(2),style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.bold)),
        Text(items.length.toString()+' expense records',style:const TextStyle(color:Colors.white70))
      ]))),
      const SizedBox(height:12),
      const Text('Recent Expenses',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      ...items.map((e)=>Card(child:ListTile(
        leading:const CircleAvatar(child:Icon(Icons.receipt)),
        title:Text(e.title,style:const TextStyle(fontWeight:FontWeight.w600)),
        subtitle:Text(e.category+' • '+e.status),
        trailing:Text('₹'+e.amount.toStringAsFixed(0),style:const TextStyle(fontWeight:FontWeight.bold))))),
      const SizedBox(height:80)
    ]);
  }

  Widget approvals()=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Admin Approvals',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    const Text('Accounts review followed by Director approval.'),
    const SizedBox(height:12),
    ...items.map((e)=>Card(child:ListTile(
      title:Text(e.title),subtitle:Text(e.category+' • '+e.status),
      trailing:PopupMenuButton<String>(onSelected:(v)=>setState(()=>e.status=v),
        itemBuilder:(_)=>['Accounts Approved','Director Approved','Rejected'].map((v)=>PopupMenuItem(value:v,child:Text(v))).toList()))))
  ]);

  Widget profile()=>Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(widget.isAdmin?Icons.admin_panel_settings:Icons.person,size:64,color:const Color(0xff0b5cab)),
    const SizedBox(height:12),
    Text(widget.isAdmin?'Administrator Access':'Employee Access',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const Text('MVP Version 1.1'),
    const SizedBox(height:20),
    OutlinedButton.icon(onPressed:logout,icon:const Icon(Icons.logout),label:const Text('Logout'))
  ]));
}
