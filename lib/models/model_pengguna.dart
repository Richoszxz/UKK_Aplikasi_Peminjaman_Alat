class ModelPengguna {
  final String? idUser;
  final String? userName;
  final String? email;
  final String? role;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModelPengguna({
    this.idUser,
    this.userName,
    this.email,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ModelPengguna.fromMap(Map<String, dynamic> map) {
    return ModelPengguna(
      idUser: map['id_user'],
      userName: map['username'],
      email: map['email'],
      role: map['role'],
      status: map['status'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
