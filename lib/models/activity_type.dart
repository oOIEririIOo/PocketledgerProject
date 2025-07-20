///消费活动类型枚举
enum ActivityType {
  /// 出行，例如旅行、通勤等
  travel,

  /// 娱乐，例如看电影、听音乐、玩游戏等
  entertainment,

  /// 吃喝，例如用餐、饮品、聚餐等
  food,

  /// 学习，例如阅读、上课、研究等
  study,

  /// 运动，例如跑步、健身、球类运动等
  exercise,

  /// 工作，例如办公、会议、项目等
  work,

  /// 购物，例如购买商品、逛街等
  shopping,

  /// 休闲，例如休息、放松、冥想等
  leisure,

  /// 其他未分类的活动
  other,
}

// 为 ActivityType 枚举添加扩展，用于获取本地化字符串
extension ActivityTypeExtension on ActivityType {
  String toLocalizedString() {
    switch (this) {
      case ActivityType.travel:
        return '出行';
      case ActivityType.entertainment:
        return '娱乐';
      case ActivityType.food:
        return '餐饮';
      case ActivityType.study:
        return '学习';
      case ActivityType.exercise:
        return '运动';
      case ActivityType.work:
        return '工作';
      case ActivityType.shopping:
        return '购物';
      case ActivityType.leisure:
        return '休闲';
      case ActivityType.other:
        return '其他';
      default:
        return name; // 默认返回英文名称，以防未来添加新的枚举值而忘记更新翻译
    }
  }
}
