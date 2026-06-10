

import '../../data/models/reviews_model.dart';
import '../entity/reviews_entity.dart';
import '../../../home/domain/entity/home_stats_entity.dart';

abstract class ReviewsInterface {
  Future<List<ReviewEntity>> fetchReviews();
  /// 提交评分/复习结果，参数为数据层的 `ReviewPostModel`（含 `cardId` 与 `rating`）。
  Future<void> submitReview(ReviewPostModel reviewPost);
  Future<List<ReviewStateModel>> fetchReviewStats();

  /// 获取用于复习的场景数据（优先从缓存），返回领域层的 `SceneEntity`。
  Future<SceneEntity> fetchSceneForReview(String sceneId);

  /// 把前端 outcome 文本（例如 "again","hard","good","easy"）映射为评分 1..4
  int ratingFromOutcome(String outcome);

}