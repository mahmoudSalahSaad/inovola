// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      currency: fields[3] as String,
      amountInUsd: fields[4] as double,
      category: fields[5] as ExpenseCategory,
      date: fields[6] as DateTime,
      receiptPath: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.amountInUsd)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.receiptPath)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 1;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.groceries;
      case 1:
        return ExpenseCategory.entertainment;
      case 2:
        return ExpenseCategory.transport;
      case 3:
        return ExpenseCategory.rent;
      case 4:
        return ExpenseCategory.shopping;
      case 5:
        return ExpenseCategory.newsAndPaper;
      case 6:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.groceries;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.groceries:
        writer.writeByte(0);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(1);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(2);
        break;
      case ExpenseCategory.rent:
        writer.writeByte(3);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(4);
        break;
      case ExpenseCategory.newsAndPaper:
        writer.writeByte(5);
        break;
      case ExpenseCategory.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
