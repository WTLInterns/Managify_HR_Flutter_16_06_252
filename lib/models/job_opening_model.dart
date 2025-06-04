class JobOpening {
  int? id;
  String? role;
  String? location;
  String? siteMode;
  double? positions;
  String? exprience;
  String? description;
  String? workType;
  Subadmin? subadmin;

  JobOpening(
      {this.id,
        this.role,
        this.location,
        this.siteMode,
        this.positions,
        this.exprience,
        this.description,
        this.workType,
        this.subadmin});

  JobOpening.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    location = json['location'];
    siteMode = json['siteMode'];
    positions = json['positions'];
    exprience = json['exprience'];
    description = json['description'];
    workType = json['workType'];
    subadmin = json['subadmin'] != null
        ? new Subadmin.fromJson(json['subadmin'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['location'] = this.location;
    data['siteMode'] = this.siteMode;
    data['positions'] = this.positions;
    data['exprience'] = this.exprience;
    data['description'] = this.description;
    data['workType'] = this.workType;
    if (this.subadmin != null) {
      data['subadmin'] = this.subadmin!.toJson();
    }
    return data;
  }
}

class Subadmin {
  int? id;
  String? name;
  String? lastname;
  String? stampImg;
  String? signature;
  String? email;
  String? phoneno;
  String? password;
  String? registercompanyname;
  String? companylogo;
  String? role;
  String? gstno;
  String? status;
  String? cinno;
  String? companyurl;
  String? address;
  double? latitude;
  double? longitude;

  Subadmin(
      {this.id,
        this.name,
        this.lastname,
        this.stampImg,
        this.signature,
        this.email,
        this.phoneno,
        this.password,
        this.registercompanyname,
        this.companylogo,
        this.role,
        this.gstno,
        this.status,
        this.cinno,
        this.companyurl,
        this.address,
        this.latitude,
        this.longitude});

  Subadmin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastname = json['lastname'];
    stampImg = json['stampImg'];
    signature = json['signature'];
    email = json['email'];
    phoneno = json['phoneno'];
    password = json['password'];
    registercompanyname = json['registercompanyname'];
    companylogo = json['companylogo'];
    role = json['role'];
    gstno = json['gstno'];
    status = json['status'];
    cinno = json['cinno'];
    companyurl = json['companyurl'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['lastname'] = this.lastname;
    data['stampImg'] = this.stampImg;
    data['signature'] = this.signature;
    data['email'] = this.email;
    data['phoneno'] = this.phoneno;
    data['password'] = this.password;
    data['registercompanyname'] = this.registercompanyname;
    data['companylogo'] = this.companylogo;
    data['role'] = this.role;
    data['gstno'] = this.gstno;
    data['status'] = this.status;
    data['cinno'] = this.cinno;
    data['companyurl'] = this.companyurl;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
