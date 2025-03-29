import 'dart:convert';

TemplateModel templateModelFromJson(String str) => TemplateModel.fromJson(json.decode(str));

String templateModelToJson(TemplateModel data) => json.encode(data.toJson());

class TemplateModel {
  final int id;
  final int documentTypeId;
  final String code;
  final String name;
  final String? format;
  final String? description;
  final int userIsEditable;
  final double basePrice;
  final double taxRate;
  final double totalPrice;
  final int requiresPayment;
  final List<TemplateSection> templateSections;

  TemplateModel({
    required this.id,
    required this.documentTypeId,
    required this.code,
    required this.name,
    this.format,
    this.description,
    required this.userIsEditable,
    required this.basePrice,
    required this.taxRate,
    required this.totalPrice,
    required this.requiresPayment,
    required this.templateSections,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] ?? 0,
      documentTypeId: json['document_type_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      format: json['format'],
      description: json['description'],
      userIsEditable: json['user_is_editable'] ?? 0,
      basePrice: (json['base_price'] ?? 0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      requiresPayment: json['requires_payment'] ?? 0,
      templateSections: (json['template_sections'] as List<dynamic>?)
              ?.map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_type_id': documentTypeId,
        'code': code,
        'name': name,
        //'format': format,
        'description': description,
        'user_is_editable': userIsEditable,
        'base_price': basePrice,
        'tax_rate': taxRate,
        'total_price': totalPrice,
        'requires_payment': requiresPayment,
        'template_sections': templateSections.map((e) => e.toJson()).toList(),
      };
}

class TemplateSection {
  final int id;
  final int templateId;
  final String name;
  final String? description;
  final String? content;
  final int userIsEditable;
  final List<TemplateField> templateFields;

  TemplateSection({
    required this.id,
    required this.templateId,
    required this.name,
    this.description,
    this.content,
    required this.userIsEditable,
    required this.templateFields,
  });

  factory TemplateSection.fromJson(Map<String, dynamic> json) {
    return TemplateSection(
      id: json['id'] ?? 0,
      templateId: json['template_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      content: json['content'],
      userIsEditable: json['user_is_editable'] ?? 0,
      templateFields: (json['template_fields'] as List<dynamic>?)
              ?.map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_id': templateId,
        'name': name,
        'description': description,
        'content': content,
        'user_is_editable': userIsEditable,
        'template_fields': templateFields.map((e) => e.toJson()).toList(),
      };
}

class TemplateField {
  final int id;
  final int sectionId;
  final String fieldName;
  final String fieldLabel;
  final String fieldType;
  final int isRequired;
  final String? fieldModel;
  final int userIsEditable;
  final List<Option> options;
  final String? description;

  TemplateField({
    required this.id,
    required this.sectionId,
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldType,
    required this.isRequired,
    this.fieldModel,
    required this.userIsEditable,
    required this.options,
    this.description,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      id: json['id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      fieldName: json['field_name'] ?? '',
      fieldLabel: json['field_label'] ?? '',
      fieldType: json['field_type'] ?? '',
      isRequired: json['is_required'] ?? 0,
      description: json['description'],
      fieldModel: json['field_model'],
      userIsEditable: json['user_is_editable'] ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'field_name': fieldName,
        'field_label': fieldLabel,
        'field_type': fieldType,
        'is_required': isRequired,
        'description': description,
        'field_model': fieldModel,
        'user_is_editable': userIsEditable,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

class Option {
  final int id;
  final String name;

  Option({
    required this.id,
    required this.name,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}